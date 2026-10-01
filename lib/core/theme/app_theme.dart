import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF375742);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF4f7059);
  static const onPrimaryContainer = Color(0xFFcdf2d5);

  static const secondary = Color(0xFF685d45);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFf0e1c2);
  static const onSecondaryContainer = Color(0xFF6e634b);

  static const tertiary = Color(0xFF5c4e43);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFF75665a);
  static const onTertiaryContainer = Color(0xFFfbe5d7);

  static const surface = Color(0xFFfcf9f2);
  static const onSurface = Color(0xFF1c1c18);
  static const surfaceContainerLow = Color(0xFFf6f3ec);
  static const surfaceContainer = Color(0xFFf1eee7);
  static const surfaceContainerHigh = Color(0xFFebe8e1);
  static const onSurfaceVariant = Color(0xFF424843);
  
  static const outline = Color(0xFF727972);
  static const outlineVariant = Color(0xFFc2c8c0);
  static const error = Color(0xFFba1a1a);

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
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainer: surfaceContainer,
        surfaceContainerHigh: surfaceContainerHigh,
        onSurfaceVariant: onSurfaceVariant,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
