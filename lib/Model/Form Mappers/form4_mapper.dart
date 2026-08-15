import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form4Mapper implements BaseFormMapper {
  @override
  int get formNumber => 4;

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    final ans = formData.answers;
    return {
      'completedFormCount': 4,
      'financialStatus': (ans['financialStatus'] ?? '').toString().trim(),
      'financeExpectation': (ans['financeExpectation'] ?? '').toString().trim(),
      'jammatContribution': (ans['jammatContribution'] ?? '').toString().trim(),
      'ownAmount': (ans['ownAmount'] ?? '').toString().trim(),
      'ownPercentage': (ans['ownPercentage'] ?? '').toString().trim(),
      'earningMembers':
          int.tryParse((ans['earningMembers'] ?? '0').toString()) ?? 0,
      'dependentMembers':
          int.tryParse((ans['dependentMembers'] ?? '0').toString()) ?? 0,
    };
  }
}
