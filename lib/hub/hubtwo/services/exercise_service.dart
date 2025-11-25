// lib/hub/hubtwo/services/exercise_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../../../Hub/HubThree/data/initial_exercises.dart';

class ExerciseService {
  static const String _key = 'custom_exercises';

  static Future<List<Exercise>> getAllExercises() async {
    final baseExercises = getBaseExercises();
    final customExercises = await _loadCustomExercises();
    return [...baseExercises, ...customExercises];
  }

  static Future<void> saveCustomExercises(List<Exercise> customExercises) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      customExercises.where((e) => e.isCustom).map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);
  }

  static Future<List<Exercise>> _loadCustomExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .where((e) => e.isCustom)
        .toList();
  }

  static Future<void> addCustomExercise(Exercise exercise) async {
    if (!exercise.isCustom) {
      throw ArgumentError('Only custom exercises can be added');
    }
    final custom = await _loadCustomExercises();
    custom.add(exercise);
    await saveCustomExercises(custom);
  }

  static Future<void> removeCustomExercise(String id) async {
    final custom = await _loadCustomExercises();
    custom.removeWhere((e) => e.id == id);
    await saveCustomExercises(custom);
  }
}