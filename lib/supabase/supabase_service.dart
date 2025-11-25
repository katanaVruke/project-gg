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

  static Future<void> addIngredient(String userId, Map<String, dynamic> ingredientData) async {
    try {
      await SupabaseHelper.client
          .from('user_ingredients')
          .insert({
        'user_id': userId,
        'name': ingredientData['name'],
        'kcal': ingredientData['kcal'],
        'protein': ingredientData['protein'],
        'fat': ingredientData['fat'],
        'carbs': ingredientData['carbs'],
      });

      if (kDebugMode) {
        print('Ингредиент успешно добавлен в Supabase: ${ingredientData['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении ингредиента в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> updateIngredient(String userId, String oldName, Map<String, dynamic> updatedData) async {
    try {
      await SupabaseHelper.client
          .from('user_ingredients')
          .update({
        'name': updatedData['name'],
        'kcal': updatedData['kcal'],
        'protein': updatedData['protein'],
        'fat': updatedData['fat'],
        'carbs': updatedData['carbs'],
      })
          .eq('user_id', userId)
          .eq('name', oldName);

      if (kDebugMode) {
        print('Ингредиент успешно обновлён в Supabase: ${updatedData['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении ингредиента в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteIngredient(String userId, String name) async {
    try {
      await SupabaseHelper.client
          .from('user_ingredients')
          .delete()
          .eq('user_id', userId)
          .eq('name', name);

      if (kDebugMode) {
        print('Ингредиент успешно удалён из Supabase: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении ингредиента из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> getUserIngredients(String userId) async {
    try {
      final response = await SupabaseHelper.client
          .from('user_ingredients')
          .select()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Ингредиенты успешно загружены из Supabase. Количество: ${response.length}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении ингредиентов из Supabase: $e');
      }
      return null;
    }
  }

  static Future<void> syncIngredientsToSupabase(String userId, List<Map<String, dynamic>> ingredientsData) async {
    try {
      await SupabaseHelper.client
          .from('user_ingredients')
          .delete()
          .eq('user_id', userId);

      if (ingredientsData.isNotEmpty) {
        await SupabaseHelper.client
            .from('user_ingredients')
            .insert(ingredientsData);
      }

      if (kDebugMode) {
        print('Ингредиенты успешно синхронизированы с Supabase. Количество: ${ingredientsData.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при синхронизации ингредиентов с Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> clearUserIngredients(String userId) async {
    try {
      await SupabaseHelper.client
          .from('user_ingredients')
          .delete()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Ингредиенты пользователя успешно очищены из Supabase для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при очистке ингредиентов пользователя из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> addDish(String userId, Map<String, dynamic> dishData) async {
    try {
      final newDish = Map<String, dynamic>.from(dishData);
      newDish.remove('id');
      newDish['user_id'] = userId;

      await SupabaseHelper.client
          .from('user_dishes')
          .insert(newDish);

      if (kDebugMode) {
        print('Блюдо успешно добавлено в Supabase: ${dishData['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении блюда в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> updateDish(String userId, String oldName, Map<String, dynamic> updatedData) async {
    try {
      await SupabaseHelper.client
          .from('user_dishes')
          .update({
        'name': updatedData['name'],
        'ingredients': updatedData['ingredients'],
      })
          .eq('user_id', userId)
          .eq('name', oldName);

      if (kDebugMode) {
        print('Блюдо успешно обновлено в Supabase: ${updatedData['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении блюда в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteDish(String userId, String name) async {
    try {
      await SupabaseHelper.client
          .from('user_dishes')
          .delete()
          .eq('user_id', userId)
          .eq('name', name);

      if (kDebugMode) {
        print('Блюдо успешно удалено из Supabase: $name');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении блюда из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> getUserDishes(String userId) async {
    try {
      final response = await SupabaseHelper.client
          .from('user_dishes')
          .select()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Блюда успешно загружены из Supabase. Количество: ${response.length}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении блюд из Supabase: $e');
      }
      return null;
    }
  }

  static Future<void> syncDishesToSupabase(String userId, List<Map<String, dynamic>> dishesData) async {
    try {
      await SupabaseHelper.client
          .from('user_dishes')
          .delete()
          .eq('user_id', userId);

      if (dishesData.isNotEmpty) {
        final dishesDataWithUserId = dishesData.map((dish) {
          final newDish = Map<String, dynamic>.from(dish);
          newDish.remove('id');
          newDish['user_id'] = userId;
          return newDish;
        }).toList();

        await SupabaseHelper.client
            .from('user_dishes')
            .insert(dishesDataWithUserId);
      }

      if (kDebugMode) {
        print('Блюда успешно синхронизированы с Supabase. Количество: ${dishesData.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при синхронизации блюд с Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> addEatenDish(String userId, Map<String, dynamic> eatenDishData) async {
    try {
      final newDish = Map<String, dynamic>.from(eatenDishData);
      newDish.remove('id');
      newDish['dish_name'] = newDish.remove('name');
      newDish['user_id'] = userId;

      await SupabaseHelper.client
          .from('eaten_dishes')
          .insert(newDish);

      if (kDebugMode) {
        print('Съеденное блюдо успешно добавлено в Supabase: ${eatenDishData['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при добавлении съеденного блюда в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> updateEatenDish(String userId, String oldDishName, String date, Map<String, dynamic> updatedData) async {
    try {
      await SupabaseHelper.client
          .from('eaten_dishes')
          .update({
        'dish_name': updatedData['name'],
        'weight': updatedData['weight'],
        'total_kcal': updatedData['total_kcal'],
        'total_protein': updatedData['total_protein'],
        'total_fat': updatedData['total_fat'],
        'total_carbs': updatedData['total_carbs'],
      })
          .eq('user_id', userId)
          .eq('dish_name', oldDishName)
          .eq('date', date);

      if (kDebugMode) {
        print('Съеденное блюдо успешно обновлено в Supabase: ${updatedData['name']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при обновлении съеденного блюда в Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> deleteEatenDish(String userId, String dishName, String date) async {
    try {
      await SupabaseHelper.client
          .from('eaten_dishes')
          .delete()
          .eq('user_id', userId)
          .eq('dish_name', dishName)
          .eq('date', date);

      if (kDebugMode) {
        print('Съеденное блюдо успешно удалено из Supabase: $dishName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении съеденного блюда из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>?> getEatenDishesForDate(String userId, String date) async {
    try {
      final response = await SupabaseHelper.client
          .from('eaten_dishes')
          .select()
          .eq('user_id', userId)
          .eq('date', date);

      if (kDebugMode) {
        print('Съеденные блюда за $date успешно загружены из Supabase. Количество: ${response.length}');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при получении съеденных блюд из Supabase: $e');
      }
      return null;
    }
  }

  static Future<void> syncEatenDishesForDateToSupabase(String userId, String date, List<Map<String, dynamic>> eatenDishesData) async {
    try {
      await SupabaseHelper.client
          .from('eaten_dishes')
          .delete()
          .eq('user_id', userId)
          .eq('date', date);

      if (eatenDishesData.isNotEmpty) {
        final eatenDishesDataWithUserId = eatenDishesData.map((dish) {
          final newDish = Map<String, dynamic>.from(dish);
          newDish.remove('id');
          newDish['dish_name'] = newDish.remove('name');
          newDish['user_id'] = userId;
          newDish['date'] = date;
          return newDish;
        }).toList();

        await SupabaseHelper.client
            .from('eaten_dishes')
            .insert(eatenDishesDataWithUserId);
      }

    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при синхронизации съеденных блюд с Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> clearUserDishes(String userId) async {
    try {
      await SupabaseHelper.client
          .from('user_dishes')
          .delete()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Блюда пользователя успешно очищены из Supabase для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при очистке блюд пользователя из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> clearEatenDishesForUser(String userId) async {
    try {
      await SupabaseHelper.client
          .from('eaten_dishes')
          .delete()
          .eq('user_id', userId);

      if (kDebugMode) {
        print('Съеденные блюда пользователя успешно очищены из Supabase для пользователя: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при очистке съеденных блюд пользователя из Supabase: $e');
      }
      rethrow;
    }
  }

  static Future<void> syncUserDataToSupabase() async {
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
    }
  }
}