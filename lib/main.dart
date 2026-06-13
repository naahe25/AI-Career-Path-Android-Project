import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (dark icons on the light canvas)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFEEF1F8),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://gybgeygxxatxqpiigmra.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5YmdleWd4eGF0eHFwaWlnbXJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA0MTA3NjgsImV4cCI6MjA5NTk4Njc2OH0._RRqCTzATeklcFulaObTfu96X9PaPessK7R5cKhNGPk',
      debug: false,
    ).timeout(const Duration(seconds: 5));
  } catch (_) {
    // Continue even if Supabase fails to initialize
  }

  runApp(const ProviderScope(child: App()));
}
