import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class TemporaryFormMapper implements BaseFormMapper {
  @override
  int get formNumber => 7;

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    return {
      'buildingName': (formData.answers['buildingName'] ?? '')
          .toString()
          .trim(),
    };
  }
}
