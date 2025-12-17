// lib/splash_screen.dart
import 'package:Elite_KA/hub/hubmain.dart';
import 'package:Elite_KA/registration/auth_screen.dart';
import 'package:Elite_KA/registration/registration.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    Future.delayed(const Duration(seconds: 1), () {
      _checkUserStatusAndNavigate();
    });
  }

  Future<void> _checkUserStatusAndNavigate() async {
    final user = SupabaseHelper.client.auth.currentUser;

    if (user != null) {
      await _loadUserDataFromSupabase();

      final _ = await SharedPreferences.getInstance();
      final isRegistrationComplete = await _isRegistrationComplete(user.id);

      if (mounted) {
        if (isRegistrationComplete) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HubMain()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  Future<void> _loadUserDataFromSupabase() async {
    final user = SupabaseHelper.client.auth.currentUser;
    if (user != null) {
      try {
        final userProfile = await SupabaseService.getUserProfile(user.id);
        if (userProfile != null) {
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('selectedGender', userProfile['selected_gender'] ?? '');
          await prefs.setInt('selectedAge', userProfile['selected_age'] ?? 0);
          await prefs.setDouble('selectedHeight', userProfile['selected_height']?.toDouble() ?? 0.0);
          await prefs.setDouble('selectedWeight', userProfile['selected_weight']?.toDouble() ?? 0.0);
          await prefs.setString('selectedFatPercentage', userProfile['selected_fat_percentage'] ?? '');
          await prefs.setStringList('selectedEquipment', userProfile['selected_equipment']?.cast<String>() ?? []);
          await prefs.setBool('isRegistrationComplete', true);
        }

        final goalsActivities = await SupabaseService.getUserGoalsAndActivities(user.id);
        if (goalsActivities != null) {
          final prefs = await SharedPreferences.getInstance();

          if (goalsActivities.containsKey('selected_target')) {
            await prefs.setString('selectedTarget', goalsActivities['selected_target'] ?? '');
          }
          if (goalsActivities.containsKey('selected_activity_level')) {
            await prefs.setString('selectedActivityLevel', goalsActivities['selected_activity_level'] ?? '');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Ошибка при загрузке пользовательских данных из Supabase: $e');
        }
      }
    }
  }

  Future<bool> _isRegistrationComplete(String userId) async {
    try {
      final userProfile = await SupabaseService.getUserProfile(userId);
      if (userProfile != null) {
        final hasGender = userProfile['selected_gender'] != null &&
            userProfile['selected_gender'] != '' &&
            userProfile['selected_gender'] != 'EMPTY';
        final hasAge = userProfile['selected_age'] != null && userProfile['selected_age'] != 0;
        final hasHeight = userProfile['selected_height'] != null && userProfile['selected_height'] != 0.0;
        final hasWeight = userProfile['selected_weight'] != null && userProfile['selected_weight'] != 0.0;
        final hasFatPercentage = userProfile['selected_fat_percentage'] != null &&
            userProfile['selected_fat_percentage'] != '' &&
            userProfile['selected_fat_percentage'] != 'EMPTY';

        final isComplete = hasGender && hasAge && hasHeight && hasWeight && hasFatPercentage;

        if (kDebugMode) {
          print('_isRegistrationComplete: $isComplete');
          print('  hasGender: $hasGender (${userProfile['selected_gender']})');
          print('  hasAge: $hasAge (${userProfile['selected_age']})');
          print('  hasHeight: $hasHeight (${userProfile['selected_height']})');
          print('  hasWeight: $hasWeight (${userProfile['selected_weight']})');
          print('  hasFatPercentage: $hasFatPercentage (${userProfile['selected_fat_percentage']})');
        }

        return isComplete;
      }
      return false;

    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при проверке статуса регистрации: $e');
      }
      return false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/img/app_icon1.png',
                    width: 150,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 50),
                Center(
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.grey[800],
                        color: Colors.red,
                        strokeWidth: 6,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                'Suppression of weakness',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}