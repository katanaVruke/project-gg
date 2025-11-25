// lib/hub/hubtwo/models/completed_workout.dart

class CompletedWorkout {
  final String id;
  final String workoutName;
  final DateTime startTime;
  final DateTime endTime;
  final double totalVolume;
  final List<CompletedExercise> exercises;

  CompletedWorkout({
    required this.id,
    required this.workoutName,
    required this.startTime,
    required this.endTime,
    required this.totalVolume,
    required this.exercises,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'workoutName': workoutName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'totalVolume': totalVolume,
    'exercises': exercises.map((e) => e.toJson()).toList(),
  };

  factory CompletedWorkout.fromJson(Map<String, dynamic> json) => CompletedWorkout(
    id: json['id'] as String,
    workoutName: json['workoutName'] as String,
    startTime: DateTime.parse(json['startTime'] as String),
    endTime: DateTime.parse(json['endTime'] as String),
    totalVolume: (json['totalVolume'] as num).toDouble(),
    exercises: (json['exercises'] as List<dynamic>)
        .map((e) => CompletedExercise.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  String get formattedDate {
    final d = startTime;
    return '${d.day}.${d.month}.${d.year}';
  }

  Duration get duration => endTime.difference(startTime);
}

class CompletedExercise {
  final String exerciseName;
  final List<CompletedSet> sets;

  CompletedExercise({
    required this.exerciseName,
    required this.sets,
  });

  Map<String, dynamic> toJson() => {
    'exerciseName': exerciseName,
    'sets': sets.map((s) => s.toJson()).toList(),
  };

  factory CompletedExercise.fromJson(Map<String, dynamic> json) => CompletedExercise(
    exerciseName: json['exerciseName'] as String,
    sets: (json['sets'] as List<dynamic>)
        .map((s) => CompletedSet.fromJson(s as Map<String, dynamic>))
        .toList(),
  );

  int get completedSets => sets.where((s) => s.reps > 0).length;
  int get totalSets => sets.length;
}

class CompletedSet {
  final int reps;
  final double weight;

  CompletedSet({required this.reps, required this.weight});

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
  };

  factory CompletedSet.fromJson(Map<String, dynamic> json) => CompletedSet(
    reps: json['reps'] as int,
    weight: (json['weight'] as num).toDouble(),
  );
}