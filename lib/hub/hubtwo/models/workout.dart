// lib/hub/hubtwo/models/workout.dart
import 'exercise.dart';

class WorkoutSet {
  int number;
  int weight;
  int reps;
  bool isCompleted;

  WorkoutSet({
    required this.number,
    this.weight = 0,
    this.reps = 0,
    this.isCompleted = false,
  });

  WorkoutSet copyWith({
    int? number,
    int? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return WorkoutSet(
      number: number ?? this.number,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  bool isFilled() => weight > 0 && reps > 0;

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory WorkoutSet.fromJson(Map<String, dynamic> json) {
    return WorkoutSet(
      number: json['number'] as int,
      weight: json['weight'] ?? 0,
      reps: json['reps'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class WorkoutExercise {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  List<WorkoutSet> sets;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.sets,
  });

  factory WorkoutExercise.fromExercise(Exercise exercise, {int setCount = 3}) {
    final sets = List.generate(setCount, (i) => WorkoutSet(number: i + 1));
    return WorkoutExercise(
      id: exercise.id,
      name: exercise.name,
      description: exercise.muscleGroups.join(', '),
      imageUrl: exercise.image,
      sets: sets,
    );
  }

  WorkoutExercise copyWith({List<WorkoutSet>? sets}) {
    return WorkoutExercise(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      sets: sets ?? this.sets,
    );
  }

  int get completedSets => sets.where((set) => set.isCompleted).length;
  int get totalSets => sets.length;
  bool isFullyCompleted() => completedSets == totalSets;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      sets: (json['sets'] as List)
          .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  get setCount => null;
}

class Workout {
  final String id;
  String name;
  DateTime createdAt;
  List<WorkoutExercise> exercises;

  Workout({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.exercises,
  });

  Workout copyWith({
    String? name,
    DateTime? createdAt,
    List<WorkoutExercise>? exercises,
  }) {
    return Workout(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      exercises: exercises ?? this.exercises,
    );
  }

  int get exerciseCount => exercises.length;

  int get totalVolume {
    int volume = 0;
    for (var exercise in exercises) {
      for (var set in exercise.sets) {
        if (set.isFilled()) {
          volume += set.weight * set.reps;
        }
      }
    }
    return volume;
  }

  String get formattedDate {
    final day = createdAt.day;
    final month = _getMonthName(createdAt.month);
    final year = createdAt.year;
    return '$day $month, $year';
  }

  String _getMonthName(int month) {
    const months = ['', 'янв.', 'фев.', 'мар.', 'апр.', 'май', 'июн.', 'июл.', 'авг.', 'сен.', 'окт.', 'нояб.', 'дек.'];
    return months[month];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'exercises': exercises.map((ex) => ex.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}