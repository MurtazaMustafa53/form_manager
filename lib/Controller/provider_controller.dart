import 'dart:async';
import 'package:flutter/material.dart';
import 'package:form_manager/Controller/Excel_controller.dart';
import 'package:form_manager/Controller/firebase_controller.dart';
import 'package:form_manager/Controller/local_storage_controller.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';
import 'package:form_manager/Model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  static const int temporaryFormNumber = 7;

  final FirebaseController _firebaseController = FirebaseController();

  List<PersonModel> _people = [];
  bool _isLoading = true;
  bool _isAuthLoading = true;
  StreamSubscription<List<PersonModel>>? _peopleSubscription;

  List<PersonModel> get people => _people;
  bool get isLoading => _isLoading;
  bool get isAuthLoading => _isAuthLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isDev => _currentUser?.isDev ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isViewer => _currentUser?.isViewer ?? false;
  bool get isFinance => _currentUser?.isFinance ?? false;
  bool get canAccessTemporaryForm => isDev || isFinance;
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
      UserRole role;
      if (savedRole == 'dev') {
        role = UserRole.dev;
      } else if (savedRole == 'admin') {
        role = UserRole.admin;
      } else if (savedRole == 'finance') {
        role = UserRole.finance;
      } else {
        role = UserRole.viewer;
      }

      _currentUser = UserModel(
        uid: '${savedRole}_01',
        email: savedEmail,
        role: role,
      );
    }
    _isAuthLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    UserRole? role;

    if (cleanEmail == 'dev@ibm.com' && password == 'dev123') {
      role = UserRole.dev;
    } else if (cleanEmail == 'admin@ibm.com' && password == 'admin123') {
      role = UserRole.admin;
    } else if (cleanEmail == 'finance@ibm.com' && password == 'finance123') {
      role = UserRole.finance;
    } else if (cleanEmail == 'view@ibm.com' && password == 'Ibm53') {
      role = UserRole.viewer;
    }

    if (role != null) {
      String roleString;
      if (role == UserRole.dev) {
        roleString = 'dev';
      } else if (role == UserRole.admin) {
        roleString = 'admin';
      } else if (role == UserRole.finance) {
        roleString = 'finance';
      } else {
        roleString = 'viewer';
      }

      _currentUser = UserModel(
        uid: '${roleString}_01',
        email: cleanEmail,
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', roleString);
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

  // --- FORM 3 & DATA PERSISTENCE METHODS ---

  /// Save draft locally via local storage controller
  Future<void> saveDraft(FormDataModel formData) async {
    if (formData.formNumber == temporaryFormNumber && !canAccessTemporaryForm) {
      throw Exception(
        'Unauthorized: only Dev and Finance can save the temporary form.',
      );
    }
    // Allow admin/dev to save drafts for any form.
    // Allow finance role to save drafts only for the finance form (formNumber 5).
    if (!(isAdmin || isDev || isFinance)) {
      throw Exception('Unauthorized: insufficient permissions to save draft.');
    }
    await LocalStorageController.saveFormDraft(formData);
    notifyListeners();
  }

  /// Load existing local draft if present
  FormDataModel? loadDraft(String personId, int formNumber) {
    return LocalStorageController.getFormDraft(personId, formNumber);
  }

  /// Retrieve form submitted directly to Firestore
  Future<FormDataModel?> getSubmittedForm(
    String personId,
    int formNumber,
  ) async {
    return await _firebaseController.getSubmittedForm(personId, formNumber);
  }

  Future<List<FormDataModel>> getSubmittedForms() async {
    return await _firebaseController.getSubmittedForms();
  }

  Future<void> exportReportOneToExcel(List<List<dynamic>> rows) async {
    if (!isDev && !isFinance) {
      throw Exception('Unauthorized: only Dev and Finance can export reports.');
    }
    await ExcelService.exportReportOne(rows);
  }

  /// Submit Form to Firebase and clear the local draft cache
  Future<void> submitFormToFirebase(FormDataModel formData) async {
    if (formData.formNumber == temporaryFormNumber && !canAccessTemporaryForm) {
      throw Exception(
        'Unauthorized: only Dev and Finance can submit the temporary form.',
      );
    }
    // Allow admin/dev to submit any form. Allow finance role to submit only the finance form.
    if (!(isAdmin || isDev || isFinance)) {
      throw Exception('Unauthorized: insufficient permissions to submit form.');
    }
    await _firebaseController.submitForm(formData);
    await LocalStorageController.clearFormDraft(
      formData.personId,
      formData.formNumber,
    );
    notifyListeners();
  }

  /// Delete a submitted form from Firebase (Dev, Admin, Finance allowed)
  Future<void> deleteSubmittedForm(String personId, int formNumber) async {
    if (formNumber == temporaryFormNumber && !canAccessTemporaryForm) {
      throw Exception(
        'Unauthorized: only Dev and Finance can delete the temporary form.',
      );
    }
    // Allow admin/dev to delete any form. Allow finance role to delete only the finance form.
    if (!(isAdmin || isDev || isFinance)) {
      throw Exception('Unauthorized: insufficient permissions to delete form.');
    }
    await _firebaseController.deleteForm(personId, formNumber);
    await LocalStorageController.clearFormDraft(personId, formNumber);
    notifyListeners();
  }

  // --- MANAGEMENT ACTIONS ---

  // Add Profile (Dev Only)
  Future<void> addNewPerson(PersonModel newPerson) async {
    if (!isDev) {
      throw Exception('Unauthorized: Only Dev ID can add profiles.');
    }
    await _firebaseController.addPerson(newPerson);
    notifyListeners();
  }

  // Delete Profile (Dev Only)
  Future<void> deletePerson(String personId) async {
    if (!isDev) {
      throw Exception('Unauthorized: Only Dev ID can delete profiles.');
    }
    await _firebaseController.deletePerson(personId);
    notifyListeners();
  }

  // Import Profiles from Excel (Dev Only)
  Future<void> importProfilesFromExcel() async {
    if (!isDev) {
      throw Exception('Unauthorized: Log in as Dev to import profiles.');
    }

    final rows = await ExcelService.pickAndReadExcel();
    if (rows.isEmpty) return;

    for (int i = 1; i < rows.length; i++) {
      var row = rows[i];
      if (row.isEmpty || row[0]?.value == null) continue;

      final name = row[0]?.value?.toString().trim() ?? '';
      final its = int.tryParse(row[1]?.value?.toString() ?? '0') ?? 0;
      final sfNo = int.tryParse(row[2]?.value?.toString() ?? '0') ?? 0;
      final contact = row[3]?.value?.toString().trim() ?? '';

      if (name.isNotEmpty) {
        final person = PersonModel(
          id: 'person_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          its: its,
          sfNo: sfNo,
          contact: contact,
        );
        await _firebaseController.addPerson(person);
      }
    }
    notifyListeners();
  }

  // --- EXPORT TO EXCEL METHODS ---

  /// Export Form 1 data to Excel (Dev, Admin, Finance allowed)
  Future<void> exportForm1ToExcel() async {
    if (!isDev && !isAdmin && !isFinance) {
      throw Exception(
        'Unauthorized: Only Dev, Admin, or Finance can export data.',
      );
    }
    final forms = await _firebaseController.getSubmittedForms(formNumber: 1);
    await ExcelService.exportSubmittedFormData(
      forms,
      allPeople: _people,
      formNumber: 1,
    );
  }

  /// Export Form 2 data to Excel (Dev, Admin, Finance allowed)
  Future<void> exportForm2ToExcel() async {
    if (!isDev && !isAdmin && !isFinance) {
      throw Exception(
        'Unauthorized: Only Dev, Admin, or Finance can export data.',
      );
    }
    final forms = await _firebaseController.getSubmittedForms(formNumber: 2);
    await ExcelService.exportSubmittedFormData(
      forms,
      allPeople: _people,
      formNumber: 2,
    );
  }

  /// Export Form 3 data to Excel (Dev, Admin, Finance allowed)
  Future<void> exportForm3ToExcel() async {
    if (!isDev && !isAdmin && !isFinance) {
      throw Exception(
        'Unauthorized: Only Dev, Admin, or Finance can export data.',
      );
    }
    final forms = await _firebaseController.getSubmittedForms(formNumber: 3);
    await ExcelService.exportSubmittedFormData(
      forms,
      allPeople: _people,
      formNumber: 3,
    );
  }

  /// Export Form 4 data to Excel (Dev, Admin, Finance allowed)
  Future<void> exportForm4ToExcel() async {
    if (!isDev && !isAdmin && !isFinance) {
      throw Exception(
        'Unauthorized: Only Dev, Admin, or Finance can export data.',
      );
    }
    final forms = await _firebaseController.getSubmittedForms(formNumber: 4);
    await ExcelService.exportSubmittedFormData(
      forms,
      allPeople: _people,
      formNumber: 4,
    );
  }

  /// Export Form 5 (Finance) data to Excel (Dev, Admin, Finance allowed)
  Future<void> exportForm5ToExcel() async {
    if (!isDev && !isAdmin && !isFinance) {
      throw Exception(
        'Unauthorized: Only Dev, Admin, or Finance can export data.',
      );
    }
    final forms = await _firebaseController.getSubmittedForms(formNumber: 5);
    await ExcelService.exportSubmittedFormData(
      forms,
      allPeople: _people,
      formNumber: 5,
    );
  }

  /// Export filtered profiles to Excel (Dev, Admin, Finance allowed)
  Future<void> exportFilteredProfilesToExcel(
    List<PersonModel> filteredPeople,
  ) async {
    if (!isDev && !isAdmin && !isFinance) {
      throw Exception(
        'Unauthorized: Only Dev, Admin, or Finance can export data.',
      );
    }
    await ExcelService.exportProfilesSummary(filteredPeople);
  }

  @override
  void dispose() {
    _peopleSubscription?.cancel();
    super.dispose();
  }
}
