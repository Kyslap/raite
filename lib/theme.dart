import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F46E5); // Indigo/Purple
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color background = Color(0xFFF9FAFB);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  
  static const Color iconBg = Color(0xFFEEF2FF);
}

final ThemeData appTheme = ThemeData(
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.primaryLight,
    surface: AppColors.background,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.cardBackground,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
    ),
    margin: EdgeInsets.zero,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    showUnselectedLabels: true,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
