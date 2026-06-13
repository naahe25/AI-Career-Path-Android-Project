import 'package:flutter/material.dart';

/// Light, classy palette for the modern 3D UI.
///
/// NOTE: The original (dark) constant names are intentionally preserved so the
/// entire app re-skins from this one file. `backgroundDark` is now the light
/// app canvas, `backgroundCard` is a white elevated surface, etc.
class AppColors {
  AppColors._();

  // Primary palette — refined indigo/violet
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF4B3FCF);
  static const Color primaryLight = Color(0xFFA29BFE);

  // Secondary — fresh teal/emerald
  static const Color secondary = Color(0xFF00C2A8);
  static const Color secondaryDark = Color(0xFF00A08B);

  // Accent — warm coral
  static const Color accent = Color(0xFFFF7675);

  // Backgrounds (light canvas + white surfaces)
  static const Color backgroundDark = Color(0xFFEEF1F8); // app canvas
  static const Color backgroundCard = Color(0xFFFFFFFF); // primary card
  static const Color backgroundElevated = Color(0xFFFFFFFF); // elevated sheets
  static const Color backgroundSurface = Color(0xFFF3F5FB); // inset / fields

  // Neumorphic shadow tones (for the 3D look on the light canvas)
  static const Color shadowDark = Color(0xFFD3D9E8); // bottom-right shadow
  static const Color shadowLight = Color(0xFFFFFFFF); // top-left highlight

  // Text (dark on light)
  static const Color textPrimary = Color(0xFF1B1D2A);
  static const Color textSecondary = Color(0xFF5A607A);
  static const Color textMuted = Color(0xFF9AA1B9);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders / dividers
  static const Color border = Color(0xFFE4E8F2);

  // Status
  static const Color success = Color(0xFF00C27A);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF5A5F);
  static const Color info = Color(0xFF3B82F6);

  // Difficulty colors
  static const Color beginner = Color(0xFF00C27A);
  static const Color intermediate = Color(0xFFFFB020);
  static const Color advanced = Color(0xFFFF5A5F);

  // Gradient stops
  static const List<Color> primaryGradient = [
    Color(0xFF6C5CE7),
    Color(0xFF8E7BFF),
  ];

  static const List<Color> cardGradient = [
    Color(0xFFFFFFFF),
    Color(0xFFF6F8FE),
  ];

  static const List<Color> successGradient = [
    Color(0xFF00C2A8),
    Color(0xFF00A08B),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFF8A8A),
    Color(0xFFFF6B6B),
  ];

  static const List<Color> infoGradient = [
    Color(0xFF5B9CFF),
    Color(0xFF3B82F6),
  ];
}

/// Centralized 3D / neumorphic shadow recipes used across the app.
class AppShadows {
  AppShadows._();

  /// Soft raised card on the light canvas (dual shadow = 3D depth).
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x14242C4D), // subtle bottom shadow
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0xCCFFFFFF), // top highlight
      blurRadius: 12,
      offset: Offset(0, -4),
    ),
  ];

  /// Lighter shadow for smaller/inner chips and tiles.
  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x0F1B1D2A),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
  ];

  /// Colored glow used under primary CTAs to make them "float".
  static List<BoxShadow> glow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}
