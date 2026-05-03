import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color seed = Color(0xFF00D3E8);

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightScheme,
      textTheme: _textTheme(_lightScheme),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkScheme,
      textTheme: _textTheme(_darkScheme),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: cs.onSurface, fontSize: 24),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: cs.onSurface, fontSize: 18),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant, fontSize: 16),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant, fontSize: 14),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: cs.onSurfaceVariant, fontSize: 12),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: cs.primary, fontSize: 12, letterSpacing: 1.0),
    );
  }

  static TextStyle headingStyle(BuildContext context) => Theme.of(context).textTheme.headlineMedium!;
  static TextStyle bodyStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;
  static TextStyle captionStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!;
  static TextStyle labelStyle(BuildContext context) => Theme.of(context).textTheme.labelMedium!;
}
