// lib/main.dart
import 'package:Elite_KA/splash_screen.dart';
import 'package:Elite_KA/supabase/supabase_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Supabase.initialize(
    url: 'https://xaazuyyjcngkqqkdcxfy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhhYXp1eXlqY25na3Fxa2RjeGZ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE3MzU0MjksImV4cCI6MjA3NzMxMTQyOX0.YSpeani17qda3AdH8cblD0tjIA3VBi9nK_KK6iR99Ok',
  );

  await SupabaseHelper.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoW',
      locale: const Locale('ru'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}