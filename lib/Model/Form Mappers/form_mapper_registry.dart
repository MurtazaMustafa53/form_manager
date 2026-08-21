import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form1_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form2_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form3_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form5_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form4_mapper.dart';
import 'package:form_manager/Model/Form%20Mappers/form6_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class FormMapperRegistry {
  static final Map<int, BaseFormMapper> _mappers = {
    1: Form1Mapper(),
    2: Form2Mapper(),
    3: Form3Mapper(),
    4: Form4Mapper(),
    5: Form5Mapper(),
    6: Form6Mapper(),
  };

  static Map<String, dynamic> getPersonUpdates(FormDataModel formData) {
    final mapper = _mappers[formData.formNumber];
    if (mapper != null) {
      return mapper.toPersonUpdates(formData);
    }
    return {'completedFormCount': formData.formNumber};
  }

  static Map<String, dynamic> buildSummaryFromSubmittedForms(
    List<FormDataModel> submittedForms,
  ) {
    final validForms = submittedForms.where((form) => !form.isDraft).toList()
      ..sort((a, b) => a.formNumber.compareTo(b.formNumber));

    final merged = <String, dynamic>{};
    for (final form in validForms) {
      final updates = getPersonUpdates(form);
      for (final entry in updates.entries) {
        if (entry.key == 'completedFormCount') continue;
        merged[entry.key] = entry.value;
      }
    }

    final hasExistingSolar = validForms.any(
      (form) =>
          form.formNumber == 1 &&
          (form.answers['solarWillingness'] ?? '').toString().toLowerCase() ==
              'already installed',
    );
    final requiredForms = hasExistingSolar ? {1, 2, 5, 6} : {1, 2, 3, 4, 5};
    merged['completedFormCount'] = validForms
        .map((form) => form.formNumber)
        .where(requiredForms.contains)
        .toSet()
        .length;
    merged['submittedFormNumbers'] = validForms
        .map((form) => form.formNumber)
        .where(requiredForms.contains)
        .toSet()
        .toList();
    merged['hasExistingSolarSystem'] = hasExistingSolar;
    return merged;
  }
}
