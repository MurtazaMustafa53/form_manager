import 'dart:async';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

class ExcelService {
  static List<CellValue?> _toCellRow(List<dynamic> values) {
    return values.map((value) {
      if (value == null) {
        return TextCellValue('');
      }
      if (value is int) {
        return IntCellValue(value);
      }
      if (value is double) {
        return DoubleCellValue(value);
      }
      if (value is bool) {
        return BoolCellValue(value);
      }
      return TextCellValue(value.toString());
    }).toList();
  }

  static Future<List<List<Data?>>> pickAndReadExcel() async {
    try {
      final input = web.document.createElement('input') as web.HTMLInputElement
        ..type = 'file'
        ..accept = '.xlsx,.xls';

      final completer = Completer<List<List<Data?>>>();

      input.onChange.listen((event) {
        final files = input.files;
        if (files != null && files.length > 0) {
          try {
            final file = files.item(0) as web.File;
            final reader = web.FileReader();

            (reader as dynamic).onload = (e) {
              try {
                final result = (reader as dynamic).result;
                Uint8List bytes;

                if (result is String) {
                  bytes = Uint8List.fromList(result.codeUnits);
                } else if (result is List) {
                  bytes = Uint8List.fromList(List<int>.from(result));
                } else {
                  // Try JSAny to List conversion
                  final list = (result as dynamic).toList() as List<int>;
                  bytes = Uint8List.fromList(list);
                }

                var excel = Excel.decodeBytes(bytes);
                for (var table in excel.tables.keys) {
                  completer.complete(excel.tables[table]?.rows ?? []);
                  return;
                }
                completer.complete([]);
              } catch (ex) {
                debugPrint('Error decoding excel: $ex');
                completer.complete([]);
              }
            };

            (reader as dynamic).onerror = (e) {
              debugPrint('Error reading file: $e');
              completer.complete([]);
            };

            reader.readAsArrayBuffer(file);
          } catch (ex) {
            debugPrint('Error processing file: $ex');
            completer.complete([]);
          }
        } else {
          completer.complete([]);
        }
      });

      input.click();
      return completer.future;
    } catch (e) {
      debugPrint('Error picking excel: $e');
      return [];
    }
  }

  static Future<void> exportSubmittedFormData(
    List<FormDataModel> formSubmissions, {
    required List<PersonModel> allPeople,
    required int formNumber,
  }) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Form $formNumber'];

    final Map<String, String> columnMap = {};
    final List<String> baseHeaders = [
      'Person ID',
      'Name',
      'ITS Number',
      'SF Number',
      'Contact',
    ];

    for (final submission in formSubmissions) {
      final answers = submission.answers;
      if (answers is Map) {
        for (final entry in answers.entries) {
          final key = entry.key.toString();
          if (!columnMap.containsKey(key)) {
            columnMap[key] = key;
          }
        }
      }
    }

    final allHeaders = [...baseHeaders, ...columnMap.keys.toList()];
    sheet.appendRow(_toCellRow(allHeaders));

    for (final submission in formSubmissions) {
      final person = allPeople.firstWhere(
        (p) => p.id == submission.personId,
        orElse: () =>
            PersonModel(id: submission.personId, name: '', its: 0, contact: ''),
      );

      final answerMap = submission.answers is Map
          ? Map<String, dynamic>.from(submission.answers as Map)
          : <String, dynamic>{};
      final values = <dynamic>[
        submission.personId,
        person.name,
        person.its,
        person.sfNo ?? '',
        person.contact,
      ];

      for (final key in columnMap.keys) {
        values.add(_normalizeExportValue(answerMap[key]));
      }

      sheet.appendRow(_toCellRow(values));
    }

    await _saveExcelFile(
      excel,
      'Form_${formNumber}_Full_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  static dynamic _normalizeExportValue(dynamic value) {
    if (value == null) return '';
    if (value is Map || value is List) {
      return value.toString();
    }
    if (value is num) {
      return value;
    }
    return value.toString();
  }

  /// Export form 1 data for a list of people
  static Future<void> exportForm1Data(List<PersonModel> people) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Form 1 - Personal Data'];

    // Add headers
    sheet.appendRow(
      _toCellRow([
        'Name',
        'ITS Number',
        'SF Number',
        'Contact',
        'Address',
        'Willing to Solar',
        'Landlord Approval',
        'Has Existing Solar System',
      ]),
    );

    // Add data rows
    for (final person in people) {
      sheet.appendRow(
        _toCellRow([
          person.name,
          person.its,
          person.sfNo ?? '',
          person.contact,
          person.address ?? '',
          person.willingToSolar ? 'Yes' : 'No',
          person.landlordApproval ? 'Yes' : 'No',
          person.hasExistingSolarSystem ? 'Yes' : 'No',
        ]),
      );
    }

    await _saveExcelFile(
      excel,
      'Form_1_Personal_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  /// Export form 2 data for a list of people
  static Future<void> exportForm2Data(List<PersonModel> people) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Form 2 - Appliance Inventory'];

    // Add headers
    sheet.appendRow(
      _toCellRow([
        'Name',
        'ITS Number',
        'Contact',
        'Total Wattage',
        'Finance by Momin',
        'Finance as Per Expectation',
      ]),
    );

    // Add data rows
    for (final person in people) {
      sheet.appendRow(
        _toCellRow([
          person.name,
          person.its,
          person.contact,
          person.totalWattage,
          person.financeByMomin,
          person.financeAsPerExpectation,
        ]),
      );
    }

    await _saveExcelFile(
      excel,
      'Form_2_Appliance_Inventory_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  /// Export form 3 data for a list of people
  static Future<void> exportForm3Data(List<PersonModel> people) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Form 3 - Audit Data'];

    // Add headers
    sheet.appendRow(
      _toCellRow(['Name', 'ITS Number', 'Contact', 'Has Existing UPS']),
    );

    // Add data rows
    for (final person in people) {
      sheet.appendRow(
        _toCellRow([
          person.name,
          person.its,
          person.contact,
          person.hasExistingUps ? 'Yes' : 'No',
        ]),
      );
    }

    await _saveExcelFile(
      excel,
      'Form_3_Audit_Data_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  /// Export form 4 data for a list of people
  static Future<void> exportForm4Data(List<PersonModel> people) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Form 4 - Review & Approvals'];

    // Add headers (Form 4 can have additional review fields)
    sheet.appendRow(_toCellRow(['Name', 'ITS Number', 'Contact', 'Status']));

    // Add data rows
    for (final person in people) {
      sheet.appendRow(
        _toCellRow([person.name, person.its, person.contact, 'Submitted']),
      );
    }

    await _saveExcelFile(
      excel,
      'Form_4_Review_Approvals_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  /// Export form 5 (Finance) data for a list of people
  static Future<void> exportForm5Data(List<PersonModel> people) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Form 5 - Finance'];

    // Add headers
    sheet.appendRow(
      _toCellRow([
        'Name',
        'ITS Number',
        'Contact',
        'Solar Panels (Qty)',
        'Solar Panel Amount',
        'Inverter (Qty)',
        'Inverter Amount',
        'Lithium Battery (Qty)',
        'Battery Amount',
        'Structure Type',
        'Structure (Qty)',
        'Structure Amount',
        'Own Contribution',
        'Qarzan Hasana',
        'Total Contribution',
      ]),
    );

    // Add data rows
    for (final person in people) {
      sheet.appendRow(
        _toCellRow([
          person.name,
          person.its,
          person.contact,
          person.numberOfSolarPanels,
          person.solarPanelAmount,
          person.numberOfInverter,
          person.inverterAmount,
          person.lithiumBattery,
          person.lithiumBatteryAmount,
          person.structure,
          person.structureQuantity,
          person.structureAmount,
          person.ownContribution,
          person.qarzanHasana,
          person.totalContribution,
        ]),
      );
    }

    await _saveExcelFile(
      excel,
      'Form_5_Finance_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  /// Export all profiles summary (basic info)
  static Future<void> exportProfilesSummary(List<PersonModel> people) async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Profiles Summary'];

    // Add headers
    sheet.appendRow(
      _toCellRow([
        'Name',
        'ITS Number',
        'SF Number',
        'Contact',
        'Forms Completed',
        'Progress',
      ]),
    );

    // Add data rows
    for (final person in people) {
      sheet.appendRow(
        _toCellRow([
          person.name,
          person.its,
          person.sfNo ?? '',
          person.contact,
          '${person.completedFormCount}/5',
          '${(person.progressPercentage * 100).toStringAsFixed(0)}%',
        ]),
      );
    }

    await _saveExcelFile(
      excel,
      'Profiles_Summary_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
  }

  /// Save Excel file as browser download using web package
  static Future<void> _saveExcelFile(Excel excel, String filename) async {
    try {
      final bytes = excel.encode();
      if (bytes == null) {
        debugPrint('Excel export failed: encoded file bytes were null.');
        return;
      }

      // Create a Blob from the bytes
      final blob = web.Blob(
        [bytes] as dynamic,
        web.BlobPropertyBag(
          type:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );

      // Create object URL and trigger download
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = filename
        ..style.display = 'none';

      web.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      web.URL.revokeObjectURL(url);

      debugPrint('Excel file download triggered: $filename');
    } catch (e) {
      debugPrint('Error exporting excel: $e');
    }
  }
}
