import 'package:flutter/material.dart';

/// Pythonchi brand color system.
/// Primary: deep indigo (trust, focus, "night-coding" mood)
/// Accent: Python yellow (energy, achievement, brand recognition)
class AppColors {
  AppColors._();

  // Brand core
  static const Color indigoDark = Color(0xFF0F1024);
  static const Color indigo = Color(0xFF1A1B3A);
  static const Color indigoLight = Color(0xFF4F5BD5);
  static const Color pythonYellow = Color(0xFFFFD43B);
  static const Color pythonBlue = Color(0xFF306998);

  // Semantic
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0F1024);
  static const Color darkSurface = Color(0xFF1A1B3A);
  static const Color darkSurfaceVariant = Color(0xFF252748);
  static const Color darkOnBackground = Color(0xFFF5F6FA);
  static const Color darkOnSurfaceMuted = Color(0xFFA0A3C4);
  static const Color darkBorder = Color(0xFF32345C);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDEEF7);
  static const Color lightOnBackground = Color(0xFF1A1B3A);
  static const Color lightOnSurfaceMuted = Color(0xFF6B6E8F);
  static const Color lightBorder = Color(0xFFDFE1F0);

  // Gamification
  static const Color xpGold = Color(0xFFFFD43B);
  static const Color streakOrange = Color(0xFFFF7A45);
  static const Color levelPurple = Color(0xFF9B59B6);

  // Difficulty tags
  static const Color difficultyBeginner = Color(0xFF2ECC71);
  static const Color difficultyIntermediate = Color(0xFFF39C12);
  static const Color difficultyAdvanced = Color(0xFFE74C3C);

  static const List<Color> brandGradient = [indigoLight, pythonBlue];
  static const List<Color> xpGradient = [pythonYellow, Color(0xFFFFA726)];
}
