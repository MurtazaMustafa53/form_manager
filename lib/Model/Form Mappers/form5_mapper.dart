import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form5Mapper implements BaseFormMapper {
  @override
  int get formNumber => 5;

  static double _parseMoney(dynamic value, {double defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final sanitized = value.replaceAll(',', '').trim();
      return double.tryParse(sanitized) ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    final ans = formData.answers;

    return {
      'completedFormCount': 5,
      'financeSummaryTotal': ans['summaryTotal'] ?? 0,
      'financeMaterials': ans['materials'] ?? [],
      'financeByMumin': (ans['financeByMumin'] ?? '').toString().trim(),
      'financeExpectation': (ans['financeExpectation'] ?? '').toString().trim(),
      'numberOfSolarPanels':
          int.tryParse((ans['numberOfSolarPanels'] ?? '2').toString()) ?? 2,
      'numberOfInverter':
          int.tryParse((ans['numberOfInverter'] ?? '1').toString()) ?? 1,
      'lithiumBattery':
          int.tryParse((ans['lithiumBattery'] ?? '1').toString()) ?? 1,
      'structure': (ans['structure'] ?? 'elevated').toString().trim(),
      'structureQuantity':
          int.tryParse((ans['structureQuantity'] ?? '1').toString()) ?? 1,
      'solarPanelAmount': _parseMoney(ans['solarPanelAmount']),
      'inverterAmount': _parseMoney(ans['inverterAmount']),
      'lithiumBatteryAmount': _parseMoney(ans['lithiumBatteryAmount']),
      'structureAmount': _parseMoney(ans['structureAmount']),
      'labourPrice': _parseMoney(ans['labourPrice']),
      'ownContribution': _parseMoney(ans['ownContribution']),
      'qarzanHasana': _parseMoney(ans['qarzanHasana']),
      'totalContribution': _parseMoney(ans['totalContribution']),
    };
  }
}
