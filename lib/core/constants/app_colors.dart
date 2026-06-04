import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44CC);
  static const Color primaryLight = Color(0xFF9D97FF);

  // Secondary
  static const Color secondary = Color(0xFF00D9A3);
  static const Color secondaryDark = Color(0xFF00A87E);

  // Accent
  static const Color accent = Color(0xFFFF6B6B);

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color backgroundCard = Color(0xFF1A1A2E);
  static const Color backgroundElevated = Color(0xFF16213E);
  static const Color backgroundSurface = Color(0xFF1E1E35);

  // Text
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textMuted = Color(0xFF6B6B8A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF00D9A3);
  static const Color warning = Color(0xFFFFB347);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF64B5F6);

  // Difficulty colors
  static const Color beginner = Color(0xFF00D9A3);
  static const Color intermediate = Color(0xFFFFB347);
  static const Color advanced = Color(0xFFFF6B6B);

  // Gradient stops
  static const List<Color> primaryGradient = [
    Color(0xFF6C63FF),
    Color(0xFF4B44CC),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
  ];

  static const List<Color> successGradient = [
    Color(0xFF00D9A3),
    Color(0xFF00A87E),
  ];
}
