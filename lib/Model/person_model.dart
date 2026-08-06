import 'package:cloud_firestore/cloud_firestore.dart';

class PersonModel {
  final String id;
  final String name;
  final int its;
  final int? sfNo;
  final String contact;

  // Form 1 Fields
  final String? address;
  final bool? willingToSolar;
  final bool? landlordApproval;

  // Form 2 Fields
  final double? totalWattage;
  final String? financeByMomin;
  final String? financeAsPerExpectation;

  // Completion Tracking
  final int completedFormCount;

  static const int totalForms = 3;

  PersonModel({
    required this.id,
    required this.name,
    required this.its,
    this.sfNo,
    required this.contact,
    this.address,
    this.willingToSolar,
    this.landlordApproval,
    this.totalWattage,
    this.financeByMomin,
    this.financeAsPerExpectation,
    this.completedFormCount = 0,
  });

  bool get isComplete => completedFormCount >= totalForms;

  double get progressPercentage =>
      (completedFormCount / totalForms).clamp(0.0, 1.0);

  PersonModel copyWith({
    String? id,
    String? name,
    int? its,
    int? sfNo,
    String? contact,
    String? address,
    bool? willingToSolar,
    bool? landlordApproval,
    double? totalWattage,
    String? financeByMomin,
    String? financeAsPerExpectation,
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
      totalWattage: totalWattage ?? this.totalWattage,
      financeByMomin: financeByMomin ?? this.financeByMomin,
      financeAsPerExpectation:
          financeAsPerExpectation ?? this.financeAsPerExpectation,
      completedFormCount: completedFormCount ?? this.completedFormCount,
    );
  }

  factory PersonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // Safe parser for bool fields stored as String, int, or bool in Firestore
    bool? _parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        final lower = value.trim().toLowerCase();
        if (lower == 'true' || lower == 'yes' || lower == '1') return true;
        if (lower == 'false' || lower == 'no' || lower == '0') return false;
      }
      if (value is num) return value == 1;
      return null;
    }

    // Safe parser for int fields stored as String or num
    int _parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    // Safe parser for optional int fields
    int? _parseNullableInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Safe parser for double fields stored as String or num
    double? _parseDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return PersonModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      its: _parseInt(data['its']),
      sfNo: _parseNullableInt(data['sfNo']),
      contact: data['contact']?.toString() ?? '',
      address: data['address']?.toString(),
      willingToSolar: _parseBool(data['willingToSolar']),
      landlordApproval: _parseBool(data['landlordApproval']),
      totalWattage: _parseDouble(data['totalWattage']),
      financeByMomin: data['financeByMomin']?.toString(),
      financeAsPerExpectation: data['financeAsPerExpectation']?.toString(),
      completedFormCount: _parseInt(data['completedFormCount']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'its': its,
      'sfNo': sfNo,
      'contact': contact,
      'address': address,
      'willingToSolar': willingToSolar,
      'landlordApproval': landlordApproval,
      'totalWattage': totalWattage,
      'financeByMomin': financeByMomin,
      'financeAsPerExpectation': financeAsPerExpectation,
      'completedFormCount': completedFormCount,
    };
  }
}
