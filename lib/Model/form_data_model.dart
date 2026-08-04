import 'package:cloud_firestore/cloud_firestore.dart';

class FormDataModel {
  final String id;
  final String personId;
  final int formNumber;
  final String filledByStaffId;
  final Map<String, dynamic> answers;
  final bool isDraft;
  final DateTime updatedAt;

  FormDataModel({
    required this.id,
    required this.personId,
    required this.formNumber,
    required this.filledByStaffId,
    required this.answers,
    this.isDraft = true,
    required this.updatedAt,
  });

  Map<String, dynamic> toFirestorMap() {
    return {
      'id': id,
      'personId': personId,
      'formNumber': formNumber,
      'filledByStaffId': filledByStaffId,
      'answers': answers,
      'isDraft': isDraft,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'personId': personId,
      'formNumber': formNumber,
      'filledByStaffId': filledByStaffId,
      'answers': answers,
      'isDraft': isDraft,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FormDataModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedDate;
    if (map['updatedAt'] is Timestamp) {
      parsedDate = (map['updatedAt'] as Timestamp).toDate();
    } else {
      parsedDate = DateTime.now();
    }

    return FormDataModel(
      id: doc.id,
      personId: map['personId'] ?? '',
      formNumber: map['formNumber'] ?? 1,
      filledByStaffId: map['filledByStaffId'] ?? '',
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
      isDraft: map['isDraft'] ?? true,
      updatedAt: parsedDate,
    );
  }

  factory FormDataModel.fromLocalMap(Map<String, dynamic> map) {
    return FormDataModel(
      id: map['id'] ?? '',
      personId: map['personId'] ?? '',
      formNumber: map['formNumber'] ?? 1,
      filledByStaffId: map['filledByStaffId'] ?? '',
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
      isDraft: map['isDraft'] ?? true,
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
