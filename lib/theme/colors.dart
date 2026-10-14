import 'package:flutter/material.dart';

/// Central color constants. [accents] feeds the accent picker in Settings.
class AppColors {
  AppColors._();

  /// Indigo (default) + 4 alternative accents.
  static const List<Color> accents = [
    Color(0xFF4F46E5),
    Color(0xFF0D9488),
    Color(0xFFE11D48),
    Color(0xFFEA580C),
    Color(0xFF7C3AED),
  ];
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB91C1C);
  static const Color neutral = Color(0xFF4B5563);
}
