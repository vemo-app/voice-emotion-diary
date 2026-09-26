import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      extensions: const [SemanticColors.light],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      extensions: const [SemanticColors.dark],
    );
  }
}
