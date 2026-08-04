import 'package:cloud_firestore/cloud_firestore.dart';

class PersonModel {
  final String id;
  final String name;
  final int its;
  final int sfNo;
  int completedFormCount;

  PersonModel({
    required this.id,
    required this.name,
    required this.its,
    required this.sfNo,
    this.completedFormCount = 0,
  });

  bool get isComplete => completedFormCount >= 6;

  double get progressPercentage => completedFormCount / 6.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'its': its,
      'sfNo': sfNo,
      'completedFormCount': completedFormCount,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      its: map['its'] ?? 0,
      sfNo: map['sfNo'] ?? 0,
      completedFormCount: map['completedFormCount'] ?? 0,
    );
  }

  factory PersonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PersonModel(
      id: doc.id,
      name: data['name'] ?? "",
      its: data['its'] ?? 0,
      sfNo: data['sfNo'] ?? 0,
    );
  }
}
