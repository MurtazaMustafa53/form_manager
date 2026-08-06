import 'package:form_manager/Model/form_data_model.dart';

abstract class BaseFormMapper {
  int get formNumber;

  /// Maps raw form answers to PersonModel fields for Firestore
  Map<String, dynamic> toPersonUpdates(FormDataModel formData);
}
