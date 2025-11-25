// lib/supabase/supabase_helper.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static bool _isInitialized = false;
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    if (!_isInitialized) {
      _client = Supabase.instance.client;
      _isInitialized = true;
    }
  }

  static SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase не инициализирован. Вызовите SupabaseHelper.initialize().');
    }
    return _client!;
  }

  static bool get isInitialized => _isInitialized;
}