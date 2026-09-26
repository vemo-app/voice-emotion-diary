import 'package:flutter/material.dart';

/// Fixed brand colors that stay the same across light and dark themes.
/// Variable colors (background, text, etc.) live in AppColorsExtension.
class AppColors {
  AppColors._();

  // --- Brand blues ---
  static const Color blue900 = Color(0xFF1E2A6E);
  static const Color blue700 = Color(0xFF3D5AFE);
  static const Color blue500 = Color(0xFF5B7CFA);
  static const Color blue100 = Color(0xFFE8ECFE);

  // --- Brand purples ---
  static const Color purple700 = Color(0xFF7C4DFF);
  static const Color purple500 = Color(0xFF9B7BFF);
  static const Color purple100 = Color(0xFFF0EBFF);

  // --- Fixed semantic colors ---
  static const Color success = Color(0xFF2FAE6B);
  static const Color danger = Color(0xFFE5484D);

  /// Primary brand gradient
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue700, purple700],
  );

  /// Primary button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [blue700, purple700],
  );
}
