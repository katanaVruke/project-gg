// lib/hub/hubone/hubone.dart
import 'package:Elite_KA/Hub/HubOne/Policy.dart';
import 'package:Elite_KA/Hub/HubOne/ProfilePage.dart';
import 'package:Elite_KA/hub/hubthree/services/exercise_service.dart';
import 'package:Elite_KA/hub/hubtwo/services/workout_storage_service.dart';
import 'package:Elite_KA/hub/hubtwo/services/completed_workout_storage_service.dart';
import 'package:Elite_KA/splash_screen.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HubOne extends StatefulWidget {
  const HubOne({super.key});

  @override
  State<HubOne> createState() => _HubOneState();
}

class _HubOneState extends State<HubOne> {
  String appVersion = "Version 1.0.0";
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    try {
      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user email: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    final titleFontSize = isSmallScreen ? 18.0 : 20.0;
    final paddingValue = isSmallScreen ? 16.0 : 20.0;
    final heightValue = isSmallScreen ? 12.0 : 20.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Конфигурация',
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 18.0 : 20.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userEmail != null) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(paddingValue),
                  margin: EdgeInsets.only(bottom: heightValue * 0.75),
                  child: Row(
                    children: [
                      Container(
                        width: isSmallScreen ? 36 : 40,
                        height: isSmallScreen ? 36 : 40,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.email,
                          color: Colors.black,
                          size: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 12 : 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Текущая почта',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: Colors.grey[400],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _userEmail!,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(paddingValue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: heightValue),
                    _buildSettingItem(
                      icon: Icons.person,
                      title: 'Мой Профиль',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    const Divider(color: Colors.grey, thickness: 1),
                    _buildSettingItem(
                      icon: Icons.settings,
                      title: 'Настройки',
                      onTap: () {
                        _showSettingsDialog(context);
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ),
              SizedBox(height: heightValue * 0.75),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(paddingValue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Контакты',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: heightValue),
                    _buildContactItem(
                      icon: Icons.telegram,
                      title: '@exp206',
                      onTap: () {
                        _launchTelegram('https://t.me/exp206');
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ),
              SizedBox(height: heightValue),
              Align(
                alignment: Alignment.center,
                child: Text(
                  appVersion,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10 : 12,
          horizontal: isSmallScreen ? 6 : 8,
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 36 : 40,
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 10 : 12,
          horizontal: isSmallScreen ? 6 : 8,
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 36 : 40,
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchTelegram(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.grey[900]!,
            content: Center(
              child: Text(
                'Не удалось открыть',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSettingsDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Настройки',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogButton(
                'Политика',
                Icons.policy,
                    () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PolicyPage()),
                  );
                },
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              _buildDialogButton(
                'Удалить все данные',
                Icons.delete,
                    () {
                  Navigator.pop(context);
                  _showDeleteDataConfirmationDialog(context);
                },
                isSmallScreen,
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              _buildDialogButton(
                'Выйти',
                Icons.exit_to_app,
                    () {
                  Navigator.pop(context);
                  _signOut();
                },
                isSmallScreen,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Закрыть',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogButton(
      String title,
      IconData icon,
      VoidCallback onTap,
      bool isSmallScreen,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.red,
              size: isSmallScreen ? 20 : 24,
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDataConfirmationDialog(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Подтверждение',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18.0 : 20.0,
            ),
          ),
          content: Text(
            'Вы уверены, что хотите удалить все данные приложения? Это действие нельзя отменить.',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Отмена',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteAllUserData();
              },
              child: Text(
                'ОК',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAllUserData() async {
    try {
      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null) {
        await SupabaseService.clearUserProfileData(user.id);
        await SupabaseService.clearUserGoalsAndActivities(user.id);
        await SupabaseService.clearUserIngredients(user.id);
        await SupabaseService.clearUserDishes(user.id);
        await SupabaseService.clearEatenDishesForUser(user.id);
        await ExerciseService.clearCustomExercises();
        await WorkoutStorageService.clearUserWorkouts(user.id);
        await CompletedWorkoutStorageService.clearUserCompletedWorkouts(user.id);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_workouts');
      await prefs.remove('completed_workouts');
      await prefs.clear();

      await SupabaseHelper.client.auth.signOut();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
              (Route<dynamic> route) => false,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Данные успешно удалены'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка удаления $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при удалении данных'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await SupabaseHelper.client.auth.signOut();

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SplashScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка выхода: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при выходе'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}