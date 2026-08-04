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

  // Complete only when all 6 forms are submitted
  bool get isComplete => completedFormCount >= 6;

  // Overall progress ratio across 6 forms (e.g., 3 forms completed = 50%)
  double get progressPercentage {
    if (isComplete) return 1.0;
    return (completedFormCount / 6.0).clamp(0.0, 1.0);
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

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
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      its: _parseInt(map['its']),
      sfNo: _parseInt(map['sfNo']),
      contact: map['contact']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      houseType: map['houseType']?.toString() ?? '',
      landlordNameAndContact: map['landlordNameAndContact']?.toString() ?? '',
      noOfPersons: _parseInt(map['noOfPersons']),
      rooms: map['rooms']?.toString() ?? '',
      completedFormCount: _parseInt(map['completedFormCount']),
      fieldCompletionRatio: _parseDouble(map['fieldCompletionRatio']),
    );
  }

  factory PersonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PersonModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      its: _parseInt(data['its']),
      sfNo: _parseInt(data['sfNo']),
      contact: data['contact']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      houseType: data['houseType']?.toString() ?? '',
      landlordNameAndContact: data['landlordNameAndContact']?.toString() ?? '',
      noOfPersons: _parseInt(data['noOfPersons']),
      rooms: data['rooms']?.toString() ?? '',
      completedFormCount: _parseInt(data['completedFormCount']),
      fieldCompletionRatio: _parseDouble(data['fieldCompletionRatio']),
    );
  }
}
