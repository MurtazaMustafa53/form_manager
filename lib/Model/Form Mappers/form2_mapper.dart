import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form2Mapper implements BaseFormMapper {
  @override
  int get formNumber => 2;

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    final ans = formData.answers;
    return {
      'completedFormCount': 2,
      'totalWattage':
          double.tryParse((ans['totalWatts'] ?? '0').toString()) ?? 0.0,
      'financeByMomin': (ans['financeByMumin'] ?? ans['financeByMomin'] ?? '')
          .toString()
          .trim(),
      'financeAsPerExpectation':
          (ans['financeExpectation'] ?? ans['financeAsPerExpectation'] ?? '')
              .toString()
              .trim(),
    };
  }
}
