// lib/supabase/supabase_service.dart
import 'package:flutter/foundation.dart';
import 'supabase_helper.dart';

class SupabaseService {
  static Future<void> createUserProfile(String userId, String email) async {
    try {
      await SupabaseHelper.client
          .from('user_profiles')
          .insert({
        'user_id': userId,
        'email': email,
        'selected_gender': '',
        'selected_age': null,
        'selected_height': null,
        'selected_weight': null,
        'selected_fat_percentage': '',
        'selected_equipment': [],
      });

      if (kDebugMode) {
        print('Профиль пользователя успешно создан для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при создании профиля пользователя: $e');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await SupabaseHelper.client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .limit(1);

      if (response.isNotEmpty) {
        return response[0];
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении профиля пользователя: $e');
      }
      return null;
    }
  }

  static Future<void> updateUserProfile(
      String userId, {
        String? selectedGender,
        int? selectedAge,
        double? selectedHeight,
        double? selectedWeight,
        String? selectedFatPercentage,
        List<String>? selectedEquipment,
      }) async {
    try {
      await SupabaseHelper.client
          .from('user_profiles')
          .update({
        'selected_gender': selectedGender,
        'selected_age': selectedAge,
        'selected_height': selectedHeight,
        'selected_weight': selectedWeight,
        'selected_fat_percentage': selectedFatPercentage,
        'selected_equipment': selectedEquipment,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Профиль пользователя успешно обновлён для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении профиля пользователя: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteUserProfile(String userId) async {
    try {
      await SupabaseHelper.client
          .from('user_profiles')
          .delete()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Профиль пользователя успешно удалён для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении профиля пользователя: $e');
      }
      rethrow;
    }
  }

  static Future<void> clearUserProfileData(String userId) async {
    try {
      await SupabaseHelper.client
          .from('user_profiles')
          .update({
        'selected_gender': '',
        'selected_age': null,
        'selected_height': null,
        'selected_weight': null,
        'selected_fat_percentage': '',
        'selected_equipment': [],
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Данные профиля пользователя успешно очищены для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при очистке данных профиля пользователя: $e');
      }
      rethrow;
    }
  }

  static Future<void> clearUserGoalsAndActivities(String userId) async {
    try {
      await SupabaseHelper.client
          .from('user_goals_activities')
          .update({
        'selected_target': null,
        'selected_activity_level': null,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Цели и активность пользователя успешно очищены для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при очистке целей и активности пользователя: $e');
      }
      rethrow;
    }
  }

  static Future<void> updateUserGoalsAndActivities(
      String userId, {
        String? selectedTarget,
        String? selectedActivityLevel,
      }) async {
    try {
      await SupabaseHelper.client
          .from('user_goals_activities')
          .upsert({
        'user_id': userId,
        'selected_target': selectedTarget,
        'selected_activity_level': selectedActivityLevel,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (kDebugMode) {
        print('Цели и активность пользователя успешно обновлены для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении целей и активности пользователя: $e');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserGoalsAndActivities(String userId) async {
    try {
      final response = await SupabaseHelper.client
          .from('user_goals_activities')
          .select()
          .eq('user_id', userId)
          .limit(1);

      if (response.isNotEmpty) {
        return response[0];
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении целей и активности пользователя: $e');
      }
      return null;
    }
  }

  static Future<void> syncUserDataToSupabase() async {
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
    }
  }
}