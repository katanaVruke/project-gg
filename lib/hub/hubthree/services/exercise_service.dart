//lib/hub/hubthree/service/exercise_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:Elite_KA/hub/hubtwo/models/exercise.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ExerciseService {
  static const String _localKey = 'exercises_custom';

  static Future<String?> _uploadImageToSupabase(String localPath) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('Локальный файл не существует: $localPath');
        }
        return null;
      }

      final fileName = Uri.parse(localPath).pathSegments.last;
      final userId = SupabaseHelper.client.auth.currentUser!.id;

      final fileExtension = fileName.split('.').last;
      final fileNameWithoutExt = fileName.substring(0, fileName.lastIndexOf('.'));
      final uniqueFileName = '${fileNameWithoutExt}_${Uuid().v4()}.$fileExtension';

      final uploadPath = '$userId/$uniqueFileName';

      await SupabaseHelper.client.storage
          .from('exercise-images')
          .upload(
        uploadPath,
        file,
      );

      final publicUrlPath = '$userId/$uniqueFileName';
      final publicUrl = SupabaseHelper.client.storage
          .from('exercise-images')
          .getPublicUrl(publicUrlPath);

      return publicUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке изображения в Supabase: $e');
      }
      return null;
    }
  }

  static Future<void> _deleteImageFromSupabase(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return;
    try {
      final uri = Uri.parse(imagePath);
      final pathSegments = uri.pathSegments;
      if (pathSegments.length >= 4 && pathSegments[0] == 'storage' && pathSegments[1] == 'v1' && pathSegments[2] == 'object' && pathSegments[3] == 'public') {
        final filePath = pathSegments.skip(5).join('/');
        await SupabaseHelper.client.storage.from('exercise-images').remove([filePath]);
        if (kDebugMode) {
          print('Изображение успешно удалено из Supabase: $filePath');
        }
      } else {
        if (kDebugMode) {
          print('Не удалось определить путь к файлу в Supabase: $imagePath');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении изображения из Supabase: $e');
      }
    }
  }

  static Future<List<Exercise>> getAllExercises(List<Exercise> initialExercises) async {
    final supabaseExercises = await _loadExercisesFromSupabase();
    final localExercises = await _loadLocalExercises();
    final allExercises = {...supabaseExercises.map((e) => e.id), ...localExercises.map((e) => e.id)};
    final uniqueExercises = <Exercise>[];
    uniqueExercises.addAll(supabaseExercises);
    for (final localExercise in localExercises) {
      if (!allExercises.contains(localExercise.id)) {
        uniqueExercises.add(localExercise);
      }
    }
    return [...initialExercises, ...uniqueExercises];
  }

  static Future<List<Exercise>> _loadExercisesFromSupabase() async {
    final userId = SupabaseHelper.client.auth.currentUser?.id;
    if (userId == null) return [];
    try {
      final response = await SupabaseHelper.client
          .from('user_exercises')
          .select('*')
          .eq('user_id', userId);

      return response.map((e) => _mapRowToExercise(e)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при загрузке упражнений из Supabase: $e');
      }
      return [];
    }
  }

  static Future<List<Exercise>> _loadLocalExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getStringList(_localKey) ?? [];
    return savedJson.map((e) => Exercise.fromJson(jsonDecode(e) as Map<String, dynamic>)).toList();
  }

  static Future<void> addCustomExercise(Exercise exercise) async {
    final userId = SupabaseHelper.client.auth.currentUser?.id;
    if (userId == null) return;

    String? imagePath = exercise.image;
    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      final publicUrl = await _uploadImageToSupabase(imagePath);
      if (publicUrl != null) {
        imagePath = publicUrl;
      } else {
        imagePath = null;
      }
    }

    try {
      final uuid = Uuid();
      final newExerciseId = uuid.v4();

      await SupabaseHelper.client
          .from('user_exercises')
          .insert({
        'id': newExerciseId,
        'user_id': userId,
        'name': exercise.name,
        'muscle_groups': exercise.muscleGroups,
        'equipment': exercise.equipment,
        'image_path': imagePath,
        'body_part': exercise.bodyPart,
        'is_custom': exercise.isCustom,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении упражнения в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> removeCustomExercise(String id, String? imagePath) async {
    final userId = SupabaseHelper.client.auth.currentUser?.id;
    if (userId == null) return;

    await _deleteImageFromSupabase(imagePath);

    try {
      await SupabaseHelper.client
          .from('user_exercises')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении упражнения из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> _deleteAllUserExercisesAndImagesFromSupabase() async {
    final userId = SupabaseHelper.client.auth.currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        print('Пользователь не авторизован, невозможно удалить упражнения.');
      }
      return;
    }

    try {
      final response = await SupabaseHelper.client
          .from('user_exercises')
          .select('id, image_path')
          .eq('user_id', userId);

      if (response.isEmpty) {
        if (kDebugMode) {
          print('Нет упражнений для удаления у пользователя $userId.');
        }
        return;
      }

      final exercisesToDelete = response.cast<Map<String, dynamic>>();

      final List<String> imagePathsToDelete = [];
      for (final exerciseData in exercisesToDelete) {
        final imagePath = exerciseData['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          imagePathsToDelete.add(imagePath);
        }
      }
      if (imagePathsToDelete.isNotEmpty) {
        for (final imagePath in imagePathsToDelete) {
          await _deleteImageFromSupabase(imagePath);
        }
        if (kDebugMode) {
          print('Удалено ${imagePathsToDelete.length} изображений из Supabase Storage.');
        }
      } else {
        if (kDebugMode) {
          print('Нет изображений для удаления у пользователя $userId.');
        }
      }

      await SupabaseHelper.client
          .from('user_exercises')
          .delete()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Удалено ${exercisesToDelete.length} записей упражнений из Supabase для пользователя $userId.');
      }

    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении упражнений и изображений из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> clearCustomExercises() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localKey);

    await _deleteAllUserExercisesAndImagesFromSupabase();
  }

  static Exercise _mapRowToExercise(Map<String, dynamic> row) {
    return Exercise(
      id: row['id'] as String,
      name: row['name'] as String,
      muscleGroups: List<String>.from(row['muscle_groups'] ?? []),
      equipment: row['equipment'] as String? ?? 'Нет',
      image: row['image_path'] as String? ?? '',
      bodyPart: row['body_part'] as String? ?? 'Другое',
      isCustom: row['is_custom'] as bool? ?? true,
    );
  }

}