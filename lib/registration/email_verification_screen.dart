// lib/registration/email_verification_screen.dart
import 'dart:async';
import 'package:Elite_KA/registration/registration.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:Elite_KA/supabase/supabase_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final String password;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isLoading = false;
  bool _isEmailVerified = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _checkEmailVerification();
      }
    });
  }

  Future<void> _checkEmailVerification() async {
    try {
      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        setState(() {
          _isEmailVerified = true;
        });

        _timer?.cancel();

        await SupabaseService.createUserProfile(user.id, user.email!);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка проверки почты: $e');
      }
    }
  }

  Future<void> _manualSignInAndCheck() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseHelper.client.auth.signInWithPassword(
        email: widget.email,
        password: widget.password,
      );

      final user = SupabaseHelper.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        setState(() {
          _isEmailVerified = true;
        });

        _timer?.cancel();

        await SupabaseService.createUserProfile(user.id, user.email!);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email еще не подтвержден. Проверьте вашу почту.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      String errorMessage = 'Ошибка входа';
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Подтверждение email', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 30),
              Text(
                'Проверьте вашу почту',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Мы отправили письмо с подтверждением на\n${widget.email}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Text(
                'Пожалуйста, перейдите по ссылке в письме для подтверждения email',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _manualSignInAndCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Проверить подтверждение'),
                ),
              ),
              const SizedBox(height: 20),
              if (_isEmailVerified)
                const Text(
                  'Email подтвержден! Переходим к регистрации...',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}