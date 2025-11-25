// lib/auth/auth_screen.dart
import 'package:Elite_KA/registration/email_verification_screen.dart';
import 'package:Elite_KA/splash_screen.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onRegistrationComplete;

  const AuthScreen({super.key, this.onRegistrationComplete});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoginMode = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLoginMode && _passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Пароли не совпадают'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        await SupabaseHelper.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await _loadUserDataFromSupabase();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SplashScreen()),
          );
        }
      } else {
        try {
          final signInResponse = await SupabaseHelper.client.auth.signInWithPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          if (signInResponse.user != null) {
            throw AuthException('Аккаунт с такой почтой уже существует. Пожалуйста, войдите в систему.');
          }
        } on AuthException catch (e) {
          if (!e.message.toLowerCase().contains('invalid login credentials') &&
              !e.message.toLowerCase().contains('email not confirmed') &&
              !e.message.toLowerCase().contains('email not registered')) {
            rethrow;
          }
        }

        final signUpResponse = await SupabaseHelper.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (signUpResponse.error != null) {
          final errorMessage = signUpResponse.error!.message.toLowerCase();

          if (errorMessage.contains('user already registered') ||
              errorMessage.contains('already exists') ||
              errorMessage.contains('duplicate') ||
              errorMessage.contains('unique violation')) {
            throw AuthException('Аккаунт с такой почтой уже существует. Пожалуйста, войдите в систему.');
          } else {
            throw AuthException(signUpResponse.error!.message);
          }
        }

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => EmailVerificationScreen(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            ),
          );
        }
      }
    } on AuthException catch (e) {
      String errorMessage = e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      String errorMessage = 'Неизвестная ошибка';
      if (e is AuthException) {
        errorMessage = e.message;
      } else {
        errorMessage = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(_isLoginMode ? 'Вход' : 'Регистрация',
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  _isLoginMode ? 'Войти в аккаунт' : 'Создать аккаунт',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите email';
                    }
                    if (!value.contains('@')) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пароль';
                    }
                    if (value.length < 6) {
                      return 'Пароль должен быть не менее 6 символов';
                    }
                    return null;
                  },
                ),
                if (!_isLoginMode) ...[
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Подтвердите пароль',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Подтвердите пароль';
                      }
                      return null;
                    },
                  ),
                ],
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(_isLoginMode ? 'Войти' : 'Зарегистрироваться'),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                    });
                  },
                  child: Text(
                    _isLoginMode
                        ? 'Нет аккаунта? Зарегистрироваться'
                        : 'Уже есть аккаунт? Войти',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}