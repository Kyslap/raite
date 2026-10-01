import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF375742);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF4F7059);
  static const onPrimaryContainer = Color(0xFFCDF2D5);

  static const secondary = Color(0xFF685D45);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFF0E1C2);
  static const onSecondaryContainer = Color(0xFF6E634B);

  static const tertiary = Color(0xFF5C4E43);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF75665A);
  static const onTertiaryContainer = Color(0xFFFBE5D7);

  static const surface = Color(0xFFFCF9F2);
  static const onSurface = Color(0xFF1C1C18);
  
  static const outline = Color(0xFF727972);
  static const outlineVariant = Color(0xFFC2C8C0);
  static const error = Color(0xFFBA1A1A);

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
    );
  }
}
