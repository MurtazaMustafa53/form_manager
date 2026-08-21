import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form6Mapper implements BaseFormMapper {
  @override
  int get formNumber => 6;

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    final answers = formData.answers;
    return {
      'extensionCurrentCapacity': (answers['currentCapacity'] ?? '')
          .toString()
          .trim(),
      'extensionRequiredCapacity': (answers['requiredExtensionCapacity'] ?? '')
          .toString()
          .trim(),
      'extensionFinancingMethod': (answers['financingMethod'] ?? '')
          .toString()
          .trim(),
    };
  }
}
