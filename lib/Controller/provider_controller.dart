import 'dart:async';
import 'package:flutter/material.dart';
import 'package:form_manager/Controller/firebase_controller.dart';
import 'package:form_manager/Controller/local_storage_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  final FirebaseController _firebaseController = FirebaseController();

  List<PersonModel> _people = [];
  bool _isLoading = true;
  StreamSubscription<List<PersonModel>>? _peopleSubscription;
  List<PersonModel> get people => _people;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isViewer => _currentUser?.isViewer ?? false;
  bool get isLoggedIn => _currentUser != null;

  AppProvider() {
    _initPeopleStream();
    _loadUserSession();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role');
    final savedEmail = prefs.getString('user_email');

    if (savedRole != null && savedEmail != null) {
      final role = savedRole == 'admin' ? UserRole.admin : UserRole.viewer;
      _currentUser = UserModel(
        uid: savedRole == 'admin' ? 'admin_01' : 'viewer_01',
        email: savedEmail,
        role: role,
      );
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    UserRole? role;

    if (cleanEmail == 'admin@ibm.com' && password == 'admin123') {
      role = UserRole.admin;
    } else if (cleanEmail == 'viewer@ibm.com' && password == 'viewer123') {
      role = UserRole.viewer;
    }

    if (role != null) {
      _currentUser = UserModel(
        uid: role == UserRole.admin ? 'admin_01' : 'viewer_01',
        email: cleanEmail,
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'user_role',
        role == UserRole.admin ? 'admin' : 'viewer',
      );
      await prefs.setString('user_email', cleanEmail);

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    notifyListeners();
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

  Future<void> addNewPerson(PersonModel newPerson) async {
    try {
      // Save the new person profile directly to Firebase Firestore
      await _firebaseController.addPerson(newPerson);

      // Notify listeners so the UI updates immediately
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding new person: $e');
    }
  }

  @override
  void dispose() {
    _peopleSubscription?.cancel();
    super.dispose();
  }
}
