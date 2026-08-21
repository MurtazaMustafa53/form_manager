import 'package:cloud_firestore/cloud_firestore.dart';

class PersonModel {
  final String id;
  final String name;
  final int its;
  final int? sfNo;
  final String contact;
  final String buildingName;

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

  // Form 5 / Finance configuration
  final int numberOfSolarPanels;
  final int numberOfInverter;
  final int lithiumBattery;
  final String structure;
  final int structureQuantity;
  final double solarPanelAmount;
  final double inverterAmount;
  final double lithiumBatteryAmount;
  final double structureAmount;
  final double labourPrice;
  final double ownContribution;
  final double qarzanHasana;
  final double totalContribution;

  // Completion Tracking
  final int completedFormCount;
  final List<int> submittedFormNumbers;

  static const int totalForms = 5;

  PersonModel({
    required this.id,
    required this.name,
    required this.its,
    this.sfNo,
    required this.contact,
    this.buildingName = '',
    this.address = '',
    this.willingToSolar = false,
    this.landlordApproval = false,
    this.hasExistingSolarSystem = false,
    this.totalWattage = 0.0,
    this.financeByMomin = 'No',
    this.financeAsPerExpectation = 'Unspecified',
    this.hasExistingUps = false,
    this.numberOfSolarPanels = 2,
    this.numberOfInverter = 1,
    this.lithiumBattery = 1,
    this.structure = 'elevated',
    this.structureQuantity = 1,
    this.solarPanelAmount = 0,
    this.inverterAmount = 0,
    this.lithiumBatteryAmount = 0,
    this.structureAmount = 0,
    this.labourPrice = 0,
    this.ownContribution = 0,
    this.qarzanHasana = 0,
    this.totalContribution = 0,
    this.completedFormCount = 0,
    this.submittedFormNumbers = const [],
  });

  bool get isComplete => completedFormCount >= requiredFormCount;

  double get progressPercentage =>
      (completedFormCount / requiredFormCount).clamp(0.0, 1.0);

  int get requiredFormCount => hasExistingSolarSystem ? 4 : totalForms;

  bool isFormCompleted(int formNumber) => submittedFormNumbers.isNotEmpty
      ? submittedFormNumbers.contains(formNumber)
      : completedFormCount >= formNumber;

  // Conditional Logic Getters
  bool get showSolarFields => hasExistingSolarSystem || willingToSolar;
  bool get showUpsDetails => hasExistingUps;

  PersonModel copyWith({
    String? id,
    String? name,
    int? its,
    int? sfNo,
    String? contact,
    String? buildingName,
    String? address,
    bool? willingToSolar,
    bool? landlordApproval,
    bool? hasExistingSolarSystem,
    double? totalWattage,
    String? financeByMomin,
    String? financeAsPerExpectation,
    bool? hasExistingUps,
    int? numberOfSolarPanels,
    int? numberOfInverter,
    int? lithiumBattery,
    String? structure,
    int? structureQuantity,
    double? solarPanelAmount,
    double? inverterAmount,
    double? lithiumBatteryAmount,
    double? structureAmount,
    double? labourPrice,
    double? ownContribution,
    double? qarzanHasana,
    double? totalContribution,
    int? completedFormCount,
    List<int>? submittedFormNumbers,
  }) {
    return PersonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      its: its ?? this.its,
      sfNo: sfNo ?? this.sfNo,
      contact: contact ?? this.contact,
      buildingName: buildingName ?? this.buildingName,
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
      numberOfSolarPanels: numberOfSolarPanels ?? this.numberOfSolarPanels,
      numberOfInverter: numberOfInverter ?? this.numberOfInverter,
      lithiumBattery: lithiumBattery ?? this.lithiumBattery,
      structure: structure ?? this.structure,
      structureQuantity: structureQuantity ?? this.structureQuantity,
      solarPanelAmount: solarPanelAmount ?? this.solarPanelAmount,
      inverterAmount: inverterAmount ?? this.inverterAmount,
      lithiumBatteryAmount: lithiumBatteryAmount ?? this.lithiumBatteryAmount,
      structureAmount: structureAmount ?? this.structureAmount,
      labourPrice: labourPrice ?? this.labourPrice,
      ownContribution: ownContribution ?? this.ownContribution,
      qarzanHasana: qarzanHasana ?? this.qarzanHasana,
      totalContribution: totalContribution ?? this.totalContribution,
      completedFormCount: completedFormCount ?? this.completedFormCount,
      submittedFormNumbers: submittedFormNumbers ?? this.submittedFormNumbers,
    );
  }

  factory PersonModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    bool parseBool(dynamic value, {bool defaultValue = false}) {
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

    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    int? parseNullableInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    double parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return PersonModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      its: parseInt(data['its']),
      sfNo: parseNullableInt(data['sfNo']),
      contact: data['contact']?.toString() ?? '',
      buildingName: data['buildingName']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      willingToSolar: parseBool(data['willingToSolar']),
      landlordApproval: parseBool(data['landlordApproval']),
      hasExistingSolarSystem: parseBool(data['hasExistingSolarSystem']),
      totalWattage: parseDouble(data['totalWattage'], defaultValue: 0.0),
      financeByMomin: data['financeByMomin']?.toString() ?? 'No',
      financeAsPerExpectation:
          data['financeAsPerExpectation']?.toString() ?? 'Unspecified',
      hasExistingUps: parseBool(data['hasExistingUps']),
      numberOfSolarPanels: parseInt(data['numberOfSolarPanels']) == 0
          ? 2
          : parseInt(data['numberOfSolarPanels']),
      numberOfInverter: parseInt(data['numberOfInverter']) == 0
          ? 1
          : parseInt(data['numberOfInverter']),
      lithiumBattery: parseInt(data['lithiumBattery']) == 0
          ? 1
          : parseInt(data['lithiumBattery']),
      structure: data['structure']?.toString() ?? 'elevated',
      structureQuantity: parseInt(data['structureQuantity']) == 0
          ? 1
          : parseInt(data['structureQuantity']),
      solarPanelAmount: parseDouble(
        data['solarPanelAmount'],
        defaultValue: 0.0,
      ),
      inverterAmount: parseDouble(data['inverterAmount'], defaultValue: 0.0),
      lithiumBatteryAmount: parseDouble(
        data['lithiumBatteryAmount'],
        defaultValue: 0.0,
      ),
      structureAmount: parseDouble(data['structureAmount'], defaultValue: 0.0),
      labourPrice: parseDouble(data['labourPrice'], defaultValue: 0.0),
      ownContribution: parseDouble(data['ownContribution'], defaultValue: 0.0),
      qarzanHasana: parseDouble(data['qarzanHasana'], defaultValue: 0.0),
      totalContribution: parseDouble(
        data['totalContribution'],
        defaultValue: 0.0,
      ),
      completedFormCount: parseInt(data['completedFormCount']),
      submittedFormNumbers:
          (data['submittedFormNumbers'] as List<dynamic>? ?? [])
              .map(parseInt)
              .toList(),
    );
  }

  // Ensures Form 1 & Form 2 edits are fully persisted to Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'its': its,
      'sfNo': sfNo,
      'contact': contact,
      'buildingName': buildingName,
      'address': address,
      'willingToSolar': willingToSolar,
      'landlordApproval': landlordApproval,
      'hasExistingSolarSystem': hasExistingSolarSystem,
      'totalWattage': totalWattage,
      'financeByMomin': financeByMomin,
      'financeAsPerExpectation': financeAsPerExpectation,
      'hasExistingUps': hasExistingUps,
      'numberOfSolarPanels': numberOfSolarPanels,
      'numberOfInverter': numberOfInverter,
      'lithiumBattery': lithiumBattery,
      'structure': structure,
      'structureQuantity': structureQuantity,
      'solarPanelAmount': solarPanelAmount,
      'inverterAmount': inverterAmount,
      'lithiumBatteryAmount': lithiumBatteryAmount,
      'structureAmount': structureAmount,
      'labourPrice': labourPrice,
      'ownContribution': ownContribution,
      'qarzanHasana': qarzanHasana,
      'totalContribution': totalContribution,
      'completedFormCount': completedFormCount,
      'submittedFormNumbers': submittedFormNumbers,
    };
  }
}
