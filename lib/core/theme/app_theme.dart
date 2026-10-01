import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF4F47E5);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFE0E7FF);
  static const onPrimaryContainer = Color(0xFF312E81);

  static const secondary = Color(0xFF6366F1);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFEEF2FF);
  static const onSecondaryContainer = Color(0xFF3730A3);

  static const tertiary = Color(0xFF3525CD);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFE0E7FF);
  static const onTertiaryContainer = Color(0xFF312E81);

  static const surface = Color(0xFFF8F9FB);
  static const onSurface = Color(0xFF1C1D20);
  
  static const outline = Color(0xFFD1D5DB);
  static const outlineVariant = Color(0xFFE5E7EB);
  static const error = Color(0xFFDC2626);

  static ThemeData get retroTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
        outlineVariant: outlineVariant,
        error: error,
      ),
      scaffoldBackgroundColor: surface,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: outline,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
