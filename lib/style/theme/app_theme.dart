import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.white,
    fontFamily: 'Segoe UI',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32, fontWeight: FontWeight.w900,
        color: AppColors.primaryDark, letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w800,
        color: AppColors.primaryDark,
      ),
      bodyLarge: TextStyle(
        fontSize: 15, color: AppColors.textMuted, height: 1.7,
      ),
      bodyMedium: TextStyle(
        fontSize: 13, color: AppColors.textMuted,
      ),
    ),
  );
}