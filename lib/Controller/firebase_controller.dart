import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:form_manager/Model/Form%20Mappers/form_mapper_registry.dart';
import 'package:form_manager/Model/form_data_model.dart';
import 'package:form_manager/Model/person_model.dart';

class FirebaseController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _peopleRef => _firestore.collection('people');
  CollectionReference get _formsRef => _firestore.collection('forms');

  Stream<List<PersonModel>> getPeopleStream() {
    return _peopleRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => PersonModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> addPerson(PersonModel person) async {
    await _peopleRef.doc(person.id).set(person.toMap());
  }

  Future<void> deletePerson(String personId) async {
    await _peopleRef.doc(personId).delete();
  }

  Future<void> submitForm(FormDataModel formData) async {
    // 1. Save specific form answer document
    final String docid = '${formData.personId}_form_${formData.formNumber}';
    await _formsRef.doc(docid).set(formData.toFirestorMap());

    // 2. Map payload via Model layer registry
    final Map<String, dynamic> personUpdates =
        FormMapperRegistry.getPersonUpdates(formData);

    // 3. Update summary fields on parent Person
    if (personUpdates.isNotEmpty) {
      await _peopleRef.doc(formData.personId).update(personUpdates);
    }
  }

  Future<FormDataModel?> getSubmittedForm(
    String personId,
    int formNumber,
  ) async {
    final String docId = '${personId}_form_$formNumber';
    final doc = await _formsRef.doc(docId).get();

    if (doc.exists) {
      return FormDataModel.fromFirestore(doc);
    }
    return null;
  }

  Future<List<FormDataModel>> getSubmittedForms({
    String? personId,
    int? formNumber,
  }) async {
    Query query = _formsRef;

    if (personId != null) {
      query = query.where('personId', isEqualTo: personId);
    }
    if (formNumber != null) {
      query = query.where('formNumber', isEqualTo: formNumber);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => FormDataModel.fromFirestore(doc))
        .where((form) => !form.isDraft)
        .toList();
  }

  Future<void> _rebuildPersonSummary(String personId) async {
    final personDoc = await _peopleRef.doc(personId).get();
    final existingData = personDoc.data() as Map<String, dynamic>? ?? {};
    final submittedForms = await getSubmittedForms(personId: personId);
    final summaryUpdates = FormMapperRegistry.buildSummaryFromSubmittedForms(
      submittedForms,
    );

    final defaultSummary = <String, dynamic>{
      'name': existingData['name'] ?? '',
      'its': existingData['its'] ?? 0,
      'sfNo': existingData['sfNo'] ?? 0,
      'contact': existingData['contact'] ?? '',
      'address': '',
      'willingToSolar': false,
      'landlordApproval': false,
      'hasExistingSolarSystem': false,
      'totalWattage': 0.0,
      'financeByMomin': 'No',
      'financeAsPerExpectation': 'Unspecified',
      'hasExistingUps': false,
      'numberOfSolarPanels': 2,
      'numberOfInverter': 1,
      'lithiumBattery': 1,
      'structure': 'elevated',
      'structureQuantity': 1,
      'solarPanelAmount': 0.0,
      'inverterAmount': 0.0,
      'lithiumBatteryAmount': 0.0,
      'structureAmount': 0.0,
      'ownContribution': 0.0,
      'qarzanHasana': 0.0,
      'totalContribution': 0.0,
      'completedFormCount': 0,
    };

    final rebuiltSummary = <String, dynamic>{
      ...defaultSummary,
      ...summaryUpdates,
    };

    await _peopleRef.doc(personId).set(rebuiltSummary);
  }

  Future<void> deleteForm(String personId, int formNumber) async {
    final String docId = '${personId}_form_$formNumber';
    await _formsRef.doc(docId).delete();
    await _rebuildPersonSummary(personId);
  }
}
