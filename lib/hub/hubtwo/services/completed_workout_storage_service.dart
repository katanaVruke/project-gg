// lib/hub/hubtwo/services/completed_workout_storage_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/completed_workout.dart';

class CompletedWorkoutStorageService {
  static const String _key = 'completed_workouts';
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<void> saveCompletedWorkout(CompletedWorkout workout) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current = prefs.getStringList(_key) ?? [];
    current.add(jsonEncode(workout.toJson()));
    await prefs.setStringList(_key, current);

    await _saveCompletedWorkoutToSupabase(workout);
  }

  static Future<List<CompletedWorkout>> loadCompletedWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_key) ?? [];
    if (rawList.isNotEmpty) {
      return rawList
          .map((str) => CompletedWorkout.fromJson(jsonDecode(str)))
          .toList()
        ..sort((a, b) => b.endTime.compareTo(a.endTime));
    } else {
      return _loadCompletedWorkoutsFromSupabase();
    }
  }

  static Future<void> deleteCompletedWorkout(String workoutId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        print("Пользователь не авторизован, невозможно удалить тренировку из Supabase.");
      }
      await _deleteFromSharedPreferences(workoutId);
      return;
    }

    try {
      final response = await _supabase
          .from('completed_workouts')
          .delete()
          .eq('id', workoutId)
          .eq('user_id', userId);

      if (response != null && response.length > 0) {
        if (kDebugMode) {
          print("Тренировка с ID $workoutId успешно удалена из Supabase.");
        }
      } else {
        if (kDebugMode) {
          print("Тренировка с ID $workoutId не найдена в Supabase или ошибка удаления.");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Ошибка при удалении тренировки из Supabase: $e");
      }
    }

    await _deleteFromSharedPreferences(workoutId);
  }

  static Future<void> _deleteFromSharedPreferences(String workoutIdToDelete) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawList = prefs.getStringList(_key) ?? [];

    final updatedRawList = rawList.where((str) {
      final workout = CompletedWorkout.fromJson(jsonDecode(str));
      return workout.id != workoutIdToDelete;
    }).toList();

    await prefs.setStringList(_key, updatedRawList);
    if (kDebugMode) {
      print("Тренировка с ID $workoutIdToDelete удалена из SharedPreferences.");
    }
  }

  static Future<void> clearUserCompletedWorkouts(String userId) async {
    await _supabase
        .from('completed_workouts')
        .delete()
        .eq('user_id', userId);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _saveCompletedWorkoutToSupabase(CompletedWorkout workout) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final dataToInsert = {
      'user_id': userId,
      'workout_name': workout.workoutName,
      'start_time': workout.startTime.toIso8601String(),
      'end_time': workout.endTime.toIso8601String(),
      'total_volume': workout.totalVolume,
      'exercises': workout.exercises.map((e) => e.toJson()).toList(),
    };

    await _supabase.from('completed_workouts').insert([dataToInsert]);
  }

  static Future<List<CompletedWorkout>> _loadCompletedWorkoutsFromSupabase() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('completed_workouts')
        .select()
        .eq('user_id', userId)
        .order('end_time', ascending: false);

    if (response.isNotEmpty) {
      return response
          .map((row) => _mapSupabaseRowToCompletedWorkout(row))
          .toList();
    } else {
      return [];
    }
  }

  static CompletedWorkout _mapSupabaseRowToCompletedWorkout(Map<String, dynamic> row) {
    final exercisesJson = row['exercises'] as List<dynamic>;
    final exercises = exercisesJson
        .map((e) => CompletedExercise.fromJson(e as Map<String, dynamic>))
        .toList();

    final id = row['id'] as String;

    return CompletedWorkout(
      id: id,
      workoutName: row['workout_name'] as String,
      startTime: DateTime.parse(row['start_time']),
      endTime: DateTime.parse(row['end_time']),
      totalVolume: (row['total_volume'] as num).toDouble(),
      exercises: exercises,
    );
  }
}