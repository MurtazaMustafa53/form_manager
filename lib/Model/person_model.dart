import 'package:cloud_firestore/cloud_firestore.dart';

class PersonModel {
  final String id;
  final String name;
  final int its;
  final int sfNo;
  final String contact;
  final String address;
  final String houseType;
  final String landlordNameAndContact;
  final int noOfPersons;
  final String rooms;
  int completedFormCount;
  double fieldCompletionRatio;

  PersonModel({
    required this.id,
    required this.name,
    required this.its,
    required this.sfNo,
    this.contact = '',
    this.address = '',
    this.houseType = '',
    this.landlordNameAndContact = '',
    this.noOfPersons = 0,
    this.rooms = '',
    this.completedFormCount = 0,
    this.fieldCompletionRatio = 0.0,
  });

  bool get isComplete => completedFormCount >= 1;

  double get progressPercentage => isComplete ? 1.0 : fieldCompletionRatio;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'its': its,
      'sfNo': sfNo,
      'contact': contact,
      'address': address,
      'houseType': houseType,
      'landlordNameAndContact': landlordNameAndContact,
      'noOfPersons': noOfPersons,
      'rooms': rooms,
      'completedFormCount': completedFormCount,
      'fieldCompletionRatio': fieldCompletionRatio,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      its: map['its'] ?? 0,
      sfNo: map['sfNo'] ?? 0,
      contact: map['contact'] ?? '',
      address: map['address'] ?? '',
      houseType: map['houseType'] ?? '',
      landlordNameAndContact: map['landlordNameAndContact'] ?? '',
      noOfPersons: map['noOfPersons'] ?? 0,
      rooms: map['rooms'] ?? '',
      completedFormCount: map['completedFormCount'] ?? 0,
      fieldCompletionRatio: (map['fieldCompletionRatio'] ?? 0.0).toDouble(),
    );
  }

  factory PersonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PersonModel(
      id: doc.id,
      name: data['name'] ?? "",
      its: data['its'] ?? 0,
      sfNo: data['sfNo'] ?? 0,
      contact: data['contact'] ?? '',
      address: data['address'] ?? '',
      houseType: data['houseType'] ?? '',
      landlordNameAndContact: data['landlordNameAndContact'] ?? '',
      noOfPersons: data['noOfPersons'] ?? 0,
      rooms: data['rooms'] ?? '',
      completedFormCount: data['completedFormCount'] ?? 0,
      fieldCompletionRatio: (data['fieldCompletionRatio'] ?? 0.0).toDouble(),
    );
  }
}
