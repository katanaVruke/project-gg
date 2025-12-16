// lib/hub/hubtwo/services/workout_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';

class WorkoutStorageService {
  static const String _key = 'saved_workouts';
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<Workout>> loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      return _loadWorkoutsFromSupabase();
    }
  }

  static Future<void> saveWorkouts(List<Workout> workouts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      workouts.map((w) => w.toJson()).toList(),
    );
    await prefs.setString(_key, jsonString);

    await _saveWorkoutsToSupabase(workouts);
  }

  static Future<void> deleteWorkout(String workoutId) async {
    final workouts = await loadWorkouts();
    final updatedWorkouts = workouts.where((w) => w.id != workoutId).toList();
    await saveWorkouts(updatedWorkouts);
  }

  static Future<void> clearUserWorkouts(String userId) async {
    await _supabase
        .from('user_workouts')
        .delete()
        .eq('user_id', userId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<List<Workout>> _loadWorkoutsFromSupabase() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('user_workouts')
        .select()
        .eq('user_id', userId);

    if (response.isNotEmpty) {
      return response
          .map((row) => _mapSupabaseRowToWorkout(row))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      return [];
    }
  }

  static Future<void> _saveWorkoutsToSupabase(List<Workout> workouts) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('user_workouts')
        .delete()
        .eq('user_id', userId);

    if (workouts.isNotEmpty) {
      final dataToInsert = workouts.map((workout) => {
        'user_id': userId,
        'name': workout.name,
        'exercises': workout.exercises.map((e) => e.toJson()).toList(),
        'original_created_at': workout.createdAt.toIso8601String(),
      }).toList();

      await _supabase.from('user_workouts').insert(dataToInsert);
    }
  }

  static Workout _mapSupabaseRowToWorkout(Map<String, dynamic> row) {
    final exercisesJson = row['exercises'] as List<dynamic>;
    final exercises = exercisesJson
        .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
        .toList();

    final originalCreatedAtStr = row['original_created_at'] as String?;
    final createdAt = originalCreatedAtStr != null
        ? DateTime.parse(originalCreatedAtStr)
        : DateTime.parse(row['created_at']);

    return Workout(
      id: row['id'] as String,
      name: row['name'] as String,
      createdAt: createdAt,
      exercises: exercises,
    );
  }
}