// lib/hub/hubtwo/services/completed_workout_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Elite_KA/hub/hubtwo/models/completed_workout.dart';

class CompletedWorkoutStorageService {
  static const String _key = 'completed_workouts';

  static Future<void> saveCompletedWorkout(CompletedWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];
    current.add(jsonEncode(workout.toJson()));
    await prefs.setStringList(_key, current);
  }

  static Future<List<CompletedWorkout>> loadCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_key) ?? [];
    return rawList
        .map((str) => CompletedWorkout.fromJson(jsonDecode(str)))
        .toList()
      ..sort((a, b) => b.endTime.compareTo(a.endTime));
  }
}