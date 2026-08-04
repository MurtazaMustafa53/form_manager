import 'dart:async';
import 'package:flutter/material.dart';
import 'package:form_manager/Controller/firebase_controller.dart';
import 'package:form_manager/Controller/local_storage_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseController _firebaseController = FirebaseController();

  List<PersonModel> _people = [];

  bool _isLoading = true;

  StreamSubscription<List<PersonModel>>? _peopleSubscription;

  List<PersonModel> get people => _people;
  bool get isLoading => _isLoading;

  AppProvider() {
    _initPeopleStream();
  }

  void _initPeopleStream() {
    _peopleSubscription = _firebaseController.getPeopleStream().listen((data) {
      _people = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> saveDraft(FormDataModel formData) async {
    await LocalStorageController.saveFormDraft(formData);
    notifyListeners();
  }

  Future<FormDataModel?> getSubmittedForm(
    String personId,
    int formNumber,
  ) async {
    return await _firebaseController.getSubmittedForm(personId, formNumber);
  }

  FormDataModel? loadDraft(String personId, int formNumber) {
    return LocalStorageController.getFormDraft(personId, formNumber);
  }

  Future<void> submitFormToFirebase(FormDataModel formData) async {
    await _firebaseController.submitForm(formData);
    await LocalStorageController.clearFormDraft(
      formData.personId,
      formData.formNumber,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _peopleSubscription?.cancel();
    super.dispose();
  }
}
