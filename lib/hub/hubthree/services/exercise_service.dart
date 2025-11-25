// lib/Hub/HubThree/services/exercise_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../hub/hubtwo/models/exercise.dart';

class ExerciseService {
  static const String _key = 'exercises_custom';

  static Future<List<Exercise>> loadExercises(List<Exercise> initialExercises) async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getStringList(_key) ?? [];

    final savedExercises = savedJson
        .map((e) => Exercise.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();

    return [...savedExercises, ...initialExercises];
  }

  static Future<void> saveCustomExercises(List<Exercise> customExercises) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = customExercises
        .map<String>((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }
}