import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> submitForm(FormDataModel formData) async {
    final String docid = '${formData.personId}_form_${formData.formNumber}';

    await _formsRef.doc(docid).set(formData.toFirestorMap());

    final Map<String, dynamic> ans = formData.answers;

    // Increment completedFormCount in Firestore using FieldValue.increment
    final Map<String, dynamic> personUpdates = {
      'completedFormCount': FieldValue.increment(1),
      'fieldCompletionRatio': ans['completionRatio'] ?? 1.0,
      'name': (ans['name'] ?? '').toString().trim(),
      'contact': (ans['contact'] ?? '').toString().trim(),
      'address': (ans['address'] ?? '').toString().trim(),
      'houseType': (ans['houseType'] ?? '').toString().trim(),
      'landlordName': (ans['landlordName'] ?? '').toString().trim(),
      'landlordContact': (ans['landlordContact'] ?? '').toString().trim(),
      'noOfPersons': int.tryParse((ans['noOfPersons'] ?? '0').toString()) ?? 0,
      'rooms': (ans['rooms'] ?? '').toString().trim(),
    };

    await _peopleRef.doc(formData.personId).update(personUpdates);
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
}
