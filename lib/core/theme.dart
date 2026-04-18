import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luminous Archive Color tokens
  static const Color primary = Color(0xFF81ECFF);
  static const Color primaryContainer = Color(0xFF00E3FD);
  static const Color background = Color(0xFF0C0E12);
  static const Color surface = Color(0xFF0C0E12);
  static const Color surfaceContainerHighest = Color(0xFF22262B);
  static const Color surfaceContainerHigh = Color(0xFF1C2025);
  static const Color surfaceContainer = Color(0xFF171A1E);
  static const Color surfaceContainerLow = Color(0xFF111417);
  static const Color surfaceVariant = Color(0xFF22262B);
  static const Color onSurface = Color(0xFFF8F9FE);
  static const Color onSurfaceVariant = Color(0xFFA9ABB0);
  static const Color outlineVariant = Color(0xFF46484C);

  static const Color error = Color(0xFFFF716C);
  static const Color errorContainer = Color(0xFF9F0519);

  // Custom tokens for swipe/keep
  static const Color deleteColor = error;
  static const Color keepColor = primary;
  static const Color accentColor = primary;
  static const Color tagColor = Color(0xFF10D5FF);
  static const Color shareColor = Color(0xFF599CF9);

  // Background solid
  static const BoxDecoration backgroundGradient = BoxDecoration(
    color: background,
  );

  // Typography
  static TextStyle headingStyle = GoogleFonts.manrope(
    fontWeight: FontWeight.w800,
    color: onSurface,
  );

  static TextStyle bodyStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    color: onSurfaceVariant,
  );

  static TextStyle captionStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w500,
    color: onSurfaceVariant,
  );

  static TextStyle labelStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    color: primary,
    letterSpacing: 1.0,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.transparent, // Handled by gradient/container in shell
    textTheme: TextTheme(
      headlineMedium: headingStyle.copyWith(fontSize: 24),
      bodyLarge: bodyStyle.copyWith(fontSize: 16),
      bodySmall: captionStyle.copyWith(fontSize: 12),
      labelMedium: labelStyle.copyWith(fontSize: 12),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primary,
      primaryContainer: primaryContainer,
      secondary: Color(0xFF10D5FF),
      surface: surface,
      surfaceContainerHighest: surfaceContainerHighest,
      error: error,
      errorContainer: errorContainer,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
    ),
  );
}
