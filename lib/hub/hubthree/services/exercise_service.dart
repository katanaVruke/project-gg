// lib/hub/hubthree/services/exercise_service.dart
import 'dart:convert';
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseService {
  static const String _key = 'exercises_custom';
  static Future<List<Exercise>> getAllExercises(List<Exercise> initialExercises) async {
    final customExercises = await _loadCustomExercises();
    return [...customExercises, ...initialExercises];
  }
  static Future<List<Exercise>> _loadCustomExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getStringList(_key) ?? [];
    return savedJson.map((e) => Exercise.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }
  static Future<void> _saveCustomExercisesToPrefs(List<Exercise> customExercises) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = customExercises.map<String>((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }
  static Future<void> addCustomExercise(Exercise exercise) async {
    final custom = await _loadCustomExercises();
    final existingIndex = custom.indexWhere((e) => e.id == exercise.id);

    if (existingIndex != -1) {
      custom[existingIndex] = exercise;
      if (kDebugMode) {
        print('Локальное упражнение обновлено: ${exercise.name}');
      }
    } else {
      custom.add(exercise);
      if (kDebugMode) {
        print('Локальное упражнение добавлено: ${exercise.name}');
      }
    }
    await _saveCustomExercisesToPrefs(custom);
  }
  static Future<void> removeCustomExercise(String id, String? imagePath) async {
    final custom = await _loadCustomExercises();
    custom.removeWhere((e) => e.id == id);
    await _saveCustomExercisesToPrefs(custom);
  }
  static Future<void> updateCustomExercise(Exercise exercise) async {
    final custom = await _loadCustomExercises();
    final index = custom.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      custom[index] = exercise;
      await _saveCustomExercisesToPrefs(custom);
    }
  }
  static Future<void> syncCustomExercisesToSupabase() async {
  }
  static Future<void> clearCustomExercises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
  static Future<void> saveCustomExercises(List<Exercise> exercises) async {
    await _saveCustomExercisesToPrefs(exercises);
  }
}