class PersonModel {
  final String id;
  final String name;
  final int its;
  int completedFormCount;

  PersonModel({
    required this.id,
    required this.name,
    required this.its,
    this.completedFormCount = 0,
  });

  bool get isComplete => completedFormCount >= 6;

  double get progressPercentage => completedFormCount / 6.0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'its': its,
      'completedFormCount': completedFormCount,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      its: map['its'] ?? 0,
      completedFormCount: map['completedFormCount'] ?? 0,
    );
  }
}
