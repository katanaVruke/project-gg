// lib/hub/hubtwo/services/workout_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout.dart';

class WorkoutStorageService {
  static const String _key = 'saved_workouts';

  static Future<List<Workout>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((e) => Workout.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveWorkouts(List<Workout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      workouts.map((w) => w.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }
}