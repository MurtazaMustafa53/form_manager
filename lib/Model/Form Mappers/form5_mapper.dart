import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form5Mapper implements BaseFormMapper {
  @override
  int get formNumber => 5;

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
    };
  }
}
