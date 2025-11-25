// lib/hub/hubtwo/models/exercise.dart
class Exercise {
  final String id;
  final String name;
  final List<String> muscleGroups;
  final String equipment;
  final String image;
  final String bodyPart;
  final bool isCustom;

  Exercise({
    required this.id,
    required this.name,
    required this.muscleGroups,
    required this.equipment,
    required this.image,
    required this.bodyPart,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'muscleGroups': muscleGroups,
      'equipment': equipment,
      'image': image,
      'bodyPart': bodyPart,
      'isCustom': isCustom,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroups: List<String>.from(json['muscleGroups'] ?? []),
      equipment: json['equipment'] as String? ?? 'Нет',
      image: json['image'] as String? ?? '',
      bodyPart: json['bodyPart'] as String? ?? 'Другое',
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }
}