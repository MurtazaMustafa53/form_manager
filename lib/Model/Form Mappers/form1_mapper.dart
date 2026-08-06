import 'package:form_manager/Model/Form%20Mappers/base_form_mapper.dart';
import 'package:form_manager/Model/form_data_model.dart';

class Form1Mapper implements BaseFormMapper {
  @override
  int get formNumber => 1;

  @override
  Map<String, dynamic> toPersonUpdates(FormDataModel formData) {
    final ans = formData.answers;
    return {
      'completedFormCount': 1,
      'fieldCompletionRatio': ans['completionRatio'] ?? 1.0,
      'name': (ans['name'] ?? '').toString().trim(),
      'contact': (ans['contact'] ?? '').toString().trim(),
      'address': (ans['address'] ?? '').toString().trim(),
      'houseType': (ans['houseType'] ?? '').toString().trim(),
      'landlordNameAndContact': (ans['landlordName'] ?? '').toString().trim(),
      'noOfPersons': int.tryParse((ans['noOfPersons'] ?? '0').toString()) ?? 0,
      'rooms': (ans['rooms'] ?? '').toString().trim(),
      'willingToSolar': ans['solarWillingness'] == 'Yes',
      'landlordApproval': ans['landlordApproval'] == 'Yes',
      'solarWillingness': (ans['solarWillingness'] ?? '').toString().trim(),
    };
  }
}
