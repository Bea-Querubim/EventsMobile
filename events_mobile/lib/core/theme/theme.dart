import 'package:flutter/material.dart';
import 'color_style.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    colorScheme: const ColorScheme.light(
      primary: AppColors.brand70,
      surface: AppColors.backgroundLight,
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brand70,
      surface: AppColors.backgroundDark,
    ),
  );
}
