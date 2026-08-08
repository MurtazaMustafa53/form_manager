import 'package:cloud_firestore/cloud_firestore.dart';

class PersonModel {
  final String id;
  final String name;
  final int its;
  final int? sfNo;
  final String contact;

  // Form 1 Fields
  final String? address;
  final bool willingToSolar;
  final bool landlordApproval;
  final bool hasExistingSolarSystem;

  // Form 2 Fields (With Default Values)
  final double totalWattage;
  final String financeByMomin;
  final String financeAsPerExpectation;

  // Form 3 / Electrical Flags
  final bool hasExistingUps;

  // Completion Tracking
  final int completedFormCount;

  static const int totalForms = 3;

  PersonModel({
    required this.id,
    required this.name,
    required this.its,
    this.sfNo,
    required this.contact,
    this.address = '',
    this.willingToSolar = false,
    this.landlordApproval = false,
    this.hasExistingSolarSystem = false,
    this.totalWattage = 0.0,
    this.financeByMomin = 'No',
    this.financeAsPerExpectation = 'Unspecified',
    this.hasExistingUps = false,
    this.completedFormCount = 0,
  });

  bool get isComplete => completedFormCount >= totalForms;

  double get progressPercentage =>
      (completedFormCount / totalForms).clamp(0.0, 1.0);

  // Conditional Logic Getters
  bool get showSolarFields => hasExistingSolarSystem || willingToSolar;
  bool get showUpsDetails => hasExistingUps;

  PersonModel copyWith({
    String? id,
    String? name,
    int? its,
    int? sfNo,
    String? contact,
    String? address,
    bool? willingToSolar,
    bool? landlordApproval,
    bool? hasExistingSolarSystem,
    double? totalWattage,
    String? financeByMomin,
    String? financeAsPerExpectation,
    bool? hasExistingUps,
    int? completedFormCount,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      its: its ?? this.its,
      sfNo: sfNo ?? this.sfNo,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      willingToSolar: willingToSolar ?? this.willingToSolar,
      landlordApproval: landlordApproval ?? this.landlordApproval,
      hasExistingSolarSystem:
          hasExistingSolarSystem ?? this.hasExistingSolarSystem,
      totalWattage: totalWattage ?? this.totalWattage,
      financeByMomin: financeByMomin ?? this.financeByMomin,
      financeAsPerExpectation:
          financeAsPerExpectation ?? this.financeAsPerExpectation,
      hasExistingUps: hasExistingUps ?? this.hasExistingUps,
      completedFormCount: completedFormCount ?? this.completedFormCount,
    );
  }

  factory PersonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    bool _parseBool(dynamic value, {bool defaultValue = false}) {
      if (value == null) return defaultValue;
      if (value is bool) return value;
      if (value is String) {
        final lower = value.trim().toLowerCase();
        if (lower == 'true' || lower == 'yes' || lower == '1') return true;
        if (lower == 'false' || lower == 'no' || lower == '0') return false;
      }
      if (value is num) return value == 1;
      return defaultValue;
    }

    int _parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? _parseNullableInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return PersonModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      its: _parseInt(data['its']),
      sfNo: _parseNullableInt(data['sfNo']),
      contact: data['contact']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      willingToSolar: _parseBool(data['willingToSolar']),
      landlordApproval: _parseBool(data['landlordApproval']),
      hasExistingSolarSystem: _parseBool(data['hasExistingSolarSystem']),
      totalWattage: _parseDouble(data['totalWattage'], defaultValue: 0.0),
      financeByMomin: data['financeByMomin']?.toString() ?? 'No',
      financeAsPerExpectation:
          data['financeAsPerExpectation']?.toString() ?? 'Unspecified',
      hasExistingUps: _parseBool(data['hasExistingUps']),
      completedFormCount: _parseInt(data['completedFormCount']),
    );
  }

  // Ensures Form 1 & Form 2 edits are fully persisted to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'its': its,
      'sfNo': sfNo,
      'contact': contact,
      'address': address,
      'willingToSolar': willingToSolar,
      'landlordApproval': landlordApproval,
      'hasExistingSolarSystem': hasExistingSolarSystem,
      'totalWattage': totalWattage,
      'financeByMomin': financeByMomin,
      'financeAsPerExpectation': financeAsPerExpectation,
      'hasExistingUps': hasExistingUps,
      'completedFormCount': completedFormCount,
    };
  }
}
