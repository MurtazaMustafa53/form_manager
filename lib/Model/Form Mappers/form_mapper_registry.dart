import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form1_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form2_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form3_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class FormMapperRegistry {
  static final Map<int, BaseFormMapper> _mappers = {
    1: Form1Mapper(),
    2: Form2Mapper(),
    3: Form3Mapper(),
  };

  static Map<String, dynamic> getPersonUpdates(FormDataModel formData) {
    final mapper = _mappers[formData.formNumber];
    if (mapper != null) {
      return mapper.toPersonUpdates(formData);
    }
    return {'completedFormCount': formData.formNumber};
  }
}
