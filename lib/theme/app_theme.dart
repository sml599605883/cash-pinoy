import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.purple,
        primary: AppColors.purple,
        secondary: AppColors.purpleLight,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Helvetica'),
        bodyMedium: TextStyle(fontFamily: 'Helvetica'),
      ),
    );
  }
}
