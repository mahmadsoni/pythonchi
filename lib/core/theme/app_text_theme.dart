import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system.
/// Inter -> UI text (clean, highly legible, supports Cyrillic + Tajik diacritics)
/// JetBrains Mono -> code blocks (ligature-friendly monospace)
///
/// Fonts are loaded on-demand via google_fonts (downloaded once, then
/// cached on-device) rather than bundled as raw asset files — this keeps
/// the repository small and avoids committing binary font files.
class AppTextTheme {
  AppTextTheme._();

  static TextTheme build(Color onBackground) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: onBackground, height: 1.2, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onBackground, height: 1.25, letterSpacing: -0.4),
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: onBackground, height: 1.3),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: onBackground, height: 1.3),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onBackground, height: 1.35),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onBackground),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onBackground),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onBackground),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: onBackground, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onBackground, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onBackground, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: onBackground, letterSpacing: 0.2),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onBackground),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: onBackground),
      ),
    );
  }

  static TextStyle codeBlock({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 14,
        height: 1.6,
        color: color ?? Colors.white,
      );

  static TextStyle codeInline({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
