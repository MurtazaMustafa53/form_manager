import 'dart:async';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

class ExcelService {
  static const List<String> _form1Headers = [
    'Full Name',
    'ITS Number',
    'SF Number',
    'Contact Number',
    'Complete Address',
    'House Type',
    'Total Number of Rooms',
    'Number of Family Members',
    'Are you willing to install solar',
    "Lanlord's approval",
  ];

  static const List<String> _form2Headers = [
    'Full Name',
    'ITS Number',
    'SF Number',
    'Contact Number',
    'Fan',
    'AC/DC Fan',
    'Tube Light',
    'LED Bulb',
    'Wifi Router',
    'AC 1-Ton inverter',
    'AC 1.5 ton',
    'AC 2 ton',
    'Fridge normal',
    'Fridge inverter',
    'Deep freezer normal',
    'Deep freezer inverter',
    'Dispenser',
    'Water pump 1/2 HP',
    'Water pump 1HP',
    'Boring Pump',
    'Washing Machine',
    'Iron',
    'Microwave',
    'TV',
    'KW installed',
    'Panels wattage',
    'Inverter Capacity',
    'Battery type',
    'Normal UPS installed',
    'Existing Inverter',
    'Existing Battery',
    'Alternative Backup',
    'Finance by mumim',
    'Finance as per expectation',
    'Filled by staff name',
    'Landlord name',
    'Landlord contact',
  ];

  static const List<String> _form3Headers = [
    'Full name',
    'Its number',
    'Sf number',
    'Contact number',
    'Roof type',
    'Roof size',
    'Max solar panel count',
    'Floor mount panels count',
    'Elevated mount panels count',
    'Main DB board type',
    'DC wire length',
    'AC wire length',
    'UPS wiring present',
    'UPS wiring length',
    'Separate room breaker',
    'Water tap on roof',
    'Earthing cable length',
    'DB Box',
    'Nuts and bolts',
    'Clips 1"',
    'Insulation tape',
    'AC breaker',
    'PVC pipe 3/4"',
    'Wire 7/0.29',
    'Sockets',
    'DC breaker',
    'PVC pipe 1"',
    'Wire 4mm (AC)',
    'Change over switch',
    'Screws',
    'Wire 4mm DC',
    'Indication light',
    'Rawal plugs',
    'Wire 40/0.76',
    'MC4 connectors',
    'Flexible pipe 3/4"',
    'Duct 25x25',
    'Battery cable',
    'Flexible pipe 1"',
    'Duct 1x1',
    'Thimble lugs',
    'Clips 3/4"',
    'Pipe bands',
    'Filled by staff name',
    'Survey remarks and observations',
  ];

  static const List<String> _form4Headers = [
    'Full name',
    'Its number',
    'Sf number',
    'Contact number',
    'Mardo count',
    'Bairo count',
    'Gair baligh count',
    'How many family members',
    'How many dependent family',
    'Financial status',
    'Source of income',
    'Own amount',
    'Own percentage',
    'Qarzan amount',
    'Timelength',
    'No. of months jammat contribution',
    'Finance as per expectation',
    'Filled by staff',
    'Remarks',
  ];

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

  static List<String> buildExportColumns(List<FormDataModel> formSubmissions) {
    if (formSubmissions.isEmpty) return const [];
    final first = formSubmissions.first;
    return buildExportHeaders(first.formNumber);
  }

  static List<String> buildExportHeaders(int formNumber) {
    switch (formNumber) {
      case 1:
        return _form1Headers;
      case 2:
        return _form2Headers;
      case 3:
        return _form3Headers;
      case 4:
        return _form4Headers;
      default:
        return const ['Full Name', 'ITS Number', 'SF Number', 'Contact Number'];
    }
  }

  static Map<String, dynamic> _flattenAnswers(dynamic rawValue) {
    final flattened = <String, dynamic>{};

    void walk(dynamic value, String prefix) {
      if (value is Map) {
        final map = value.map(
          (key, entryValue) => MapEntry(key.toString(), entryValue),
        );

        if (map.isEmpty) {
          if (prefix.isNotEmpty) flattened[prefix] = '';
          return;
        }

        for (final entry in map.entries) {
          final nextPrefix = prefix.isEmpty
              ? entry.key
              : '$prefix.${entry.key}';
          walk(entry.value, nextPrefix);
        }
        return;
      }

      if (value is List) {
        if (value.isEmpty) {
          if (prefix.isNotEmpty) flattened[prefix] = '';
          return;
        }

        for (int i = 0; i < value.length; i++) {
          walk(value[i], '$prefix[$i]');
        }
        return;
      }

      if (prefix.isNotEmpty) {
        flattened[prefix] = value;
      }
    }

    if (rawValue is Map) {
      walk(rawValue, '');
    }

    return flattened;
  }

  static dynamic _readAnswerValue(
    Map<String, dynamic> answerMap,
    List<String> keys,
  ) {
    for (final key in keys) {
      if (answerMap.containsKey(key)) {
        return answerMap[key];
      }
    }
    return '';
  }

  static int _intFromValue(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value.trim()) ?? defaultValue;
    }
    return defaultValue;
  }

  static double _doubleFromValue(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.trim()) ?? defaultValue;
    }
    return defaultValue;
  }

  static String _stringFromValue(dynamic value) {
    if (value == null) return '';
    if (value is bool) return value ? 'Yes' : 'No';
    return value.toString();
  }

  static List<dynamic> buildFormExportRow(
    FormDataModel submission,
    List<PersonModel> allPeople,
    int formNumber,
  ) {
    final person = allPeople.firstWhere(
      (p) => p.id == submission.personId,
      orElse: () =>
          PersonModel(id: submission.personId, name: '', its: 0, contact: ''),
    );

    final answerMap = Map<String, dynamic>.from(submission.answers);
    final applianceMap = <String, int>{};
    if (answerMap['appliances'] is List) {
      for (final item in answerMap['appliances'] as List) {
        if (item is Map) {
          final name = _stringFromValue(item['name']).trim();
          if (name.isEmpty) continue;
          applianceMap[name] = _intFromValue(item['qty'], defaultValue: 0);
        }
      }
    }

    if (formNumber == 1) {
      return [
        person.name,
        person.its,
        person.sfNo ?? '',
        person.contact,
        _readAnswerValue(answerMap, ['address']),
        _readAnswerValue(answerMap, ['houseType']),
        _readAnswerValue(answerMap, ['rooms']),
        _readAnswerValue(answerMap, ['noOfPersons']),
        _readAnswerValue(answerMap, ['solarWillingness']),
        _readAnswerValue(answerMap, ['landlordApproval']),
      ];
    }

    if (formNumber == 2) {
      final values = <dynamic>[
        person.name,
        person.its,
        person.sfNo ?? '',
        person.contact,
      ];

      for (final key in _form2Headers.skip(4)) {
        if (key == 'KW installed') {
          values.add(
            _readAnswerValue(answerMap, ['totalWatts', 'kwInstalled']),
          );
          continue;
        }
        if (key == 'Panels wattage') {
          values.add(_readAnswerValue(answerMap, ['panelsWattage']));
          continue;
        }
        if (key == 'Inverter Capacity') {
          values.add(_readAnswerValue(answerMap, ['inverterCapacity']));
          continue;
        }
        if (key == 'Battery type') {
          values.add(_readAnswerValue(answerMap, ['batteryType']));
          continue;
        }
        if (key == 'Normal UPS installed') {
          values.add(_readAnswerValue(answerMap, ['normalUpsInstalled']));
          continue;
        }
        if (key == 'Existing Inverter') {
          values.add(_readAnswerValue(answerMap, ['existingInverter']));
          continue;
        }
        if (key == 'Existing Battery') {
          values.add(_readAnswerValue(answerMap, ['existingBattery']));
          continue;
        }
        if (key == 'Alternative Backup') {
          values.add(_readAnswerValue(answerMap, ['alternativeBackup']));
          continue;
        }
        if (key == 'Finance by mumim') {
          values.add(_readAnswerValue(answerMap, ['financeByMumin']));
          continue;
        }
        if (key == 'Finance as per expectation') {
          values.add(_readAnswerValue(answerMap, ['financeExpectation']));
          continue;
        }
        if (key == 'Filled by staff name') {
          values.add(_readAnswerValue(answerMap, ['filledByStaff']));
          continue;
        }
        if (key == 'Landlord name') {
          values.add(_readAnswerValue(answerMap, ['landlordName']));
          continue;
        }
        if (key == 'Landlord contact') {
          values.add(_readAnswerValue(answerMap, ['landlordContact']));
          continue;
        }

        values.add(applianceMap[key] ?? 0);
      }

      return values;
    }

    if (formNumber == 3) {
      final materials = answerMap['materials'] is Map
          ? Map<String, dynamic>.from(answerMap['materials'] as Map)
          : <String, dynamic>{};

      final values = <dynamic>[
        person.name,
        person.its,
        person.sfNo ?? '',
        person.contact,
      ];

      for (final key in _form3Headers.skip(4)) {
        if (key == 'Roof type') {
          values.add(_readAnswerValue(answerMap, ['roofType']));
          continue;
        }
        if (key == 'Roof size') {
          values.add(_readAnswerValue(answerMap, ['roofSize']));
          continue;
        }
        if (key == 'Max solar panel count') {
          values.add(_readAnswerValue(answerMap, ['houseNoOfSolarPanels']));
          continue;
        }
        if (key == 'Floor mount panels count') {
          values.add(_readAnswerValue(answerMap, ['floorMountNoOfSolar']));
          continue;
        }
        if (key == 'Elevated mount panels count') {
          values.add(_readAnswerValue(answerMap, ['elevatedNoOfSolar']));
          continue;
        }
        if (key == 'Main DB board type') {
          values.add(_readAnswerValue(answerMap, ['mainBoardType']));
          continue;
        }
        if (key == 'DC wire length') {
          values.add(_readAnswerValue(answerMap, ['dcWireLength']));
          continue;
        }
        if (key == 'AC wire length') {
          values.add(_readAnswerValue(answerMap, ['acWireLength']));
          continue;
        }
        if (key == 'UPS wiring present') {
          values.add(_readAnswerValue(answerMap, ['upsWiring']));
          continue;
        }
        if (key == 'UPS wiring length') {
          values.add(_readAnswerValue(answerMap, ['upsWiringLength']));
          continue;
        }
        if (key == 'Separate room breaker') {
          values.add(_readAnswerValue(answerMap, ['separateRoomWiseBreakers']));
          continue;
        }
        if (key == 'Water tap on roof') {
          values.add(_readAnswerValue(answerMap, ['waterConnectionOnRoof']));
          continue;
        }
        if (key == 'Earthing cable length') {
          values.add(_readAnswerValue(answerMap, ['earthingLength']));
          continue;
        }
        if (key == 'Filled by staff name') {
          values.add(_readAnswerValue(answerMap, ['filledByStaff']));
          continue;
        }
        if (key == 'Survey remarks and observations') {
          values.add(_readAnswerValue(answerMap, ['remarks']));
          continue;
        }

        final materialKey = {
          'DB Box': 'dbBox',
          'Nuts and bolts': 'nutBolts',
          'Clips 1"': 'clip1',
          'Insulation tape': 'insulationTape',
          'AC breaker': 'acBreaker',
          'PVC pipe 3/4"': 'pipeLength34',
          'Wire 7/0.29': 'wire7029',
          'Sockets': 'socket',
          'DC breaker': 'dcBreaker',
          'PVC pipe 1"': 'pipeLength1',
          'Wire 4mm (AC)': 'acWire4mm',
          'Change over switch': 'changeOver',
          'Screws': 'screw',
          'Wire 4mm DC': 'dcWire4mm',
          'Indication light': 'indicationLights',
          'Rawal plugs': 'rawalPlug',
          'Wire 40/0.76': 'wire4076',
          'MC4 connectors': 'mc4Connector',
          'Flexible pipe 3/4"': 'flexiblePipe34',
          'Duct 25x25': 'duct25x25',
          'Battery cable': 'batteryWire',
          'Flexible pipe 1"': 'flexiblePipe1',
          'Duct 1x1': 'duct1x1',
          'Thimble lugs': 'thimble',
          'Clips 3/4"': 'clip34',
          'Pipe bands': 'band',
        }[key];

        values.add(materials[materialKey] ?? '');
      }

      return values;
    }

    if (formNumber == 4) {
      return [
        person.name,
        person.its,
        person.sfNo ?? '',
        person.contact,
        _readAnswerValue(answerMap, ['mardo']),
        _readAnswerValue(answerMap, ['bairo']),
        _readAnswerValue(answerMap, ['gairBaligh']),
        _readAnswerValue(answerMap, ['earningMembers']),
        _readAnswerValue(answerMap, ['dependentMembers']),
        _readAnswerValue(answerMap, ['financialStatus']),
        _readAnswerValue(answerMap, ['incomeSource']),
        _readAnswerValue(answerMap, ['ownAmount']),
        _readAnswerValue(answerMap, ['ownPercentage']),
        _readAnswerValue(answerMap, ['qarzanAmount']),
        _readAnswerValue(answerMap, ['hassanaTerm']),
        _readAnswerValue(answerMap, ['hassanaMonths']),
        _readAnswerValue(answerMap, ['financeExpectation']),
        _readAnswerValue(answerMap, ['formFilledBy']),
        _readAnswerValue(answerMap, ['remarks']),
      ];
    }

    return [person.name, person.its, person.sfNo ?? '', person.contact];
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

    final headers = buildExportHeaders(formNumber);
    sheet.appendRow(_toCellRow(headers));

    for (final submission in formSubmissions) {
      final row = buildFormExportRow(submission, allPeople, formNumber);
      sheet.appendRow(_toCellRow(row));
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
