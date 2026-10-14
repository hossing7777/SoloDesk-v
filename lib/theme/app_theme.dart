import 'package:flutter/material.dart';

/// Builds Material 3 light/dark themes from an accent seed color.
class AppTheme {
  AppTheme._();

  static const double radius = 16;

  static ThemeData build(Color seed, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: 'Inter',
      // Persian / Arabic glyphs come from Vazirmatn.
      fontFamilyFallback: const ['Vazirmatn'],
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black26,
        margin: const EdgeInsets.only(bottom: 12),
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: shape,
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          minimumSize: const Size(48, 48),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(shape: shape),
      dialogTheme: DialogTheme(shape: shape),
    );
  }
}
