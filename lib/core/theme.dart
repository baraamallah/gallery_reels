import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Vibrant cyan/aqua as the primary brand color
  static const Color primaryCyan = Color(0xFF00D3E8);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color surfaceDark = Color(0xFF0A0A0A); // True black for high contrast

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: primaryCyan,
    brightness: Brightness.light,
    surface: Colors.white,
    onSurface: const Color(0xFF1F2937),
    primary: primaryCyan,
    secondary: accentPurple,
  );

  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: primaryCyan,
    brightness: Brightness.dark,
    surface: surfaceDark,
    surfaceContainerLow: const Color(0xFF121212),
    surfaceContainerHigh: const Color(0xFF1E1E1E),
    onSurface: const Color(0xFFF3F4F6),
    onSurfaceVariant: const Color(0xFF9CA3AF),
    primary: primaryCyan,
    secondary: accentPurple,
    outlineVariant: const Color(0xFF262626),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightScheme,
      textTheme: _textTheme(_lightScheme),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkScheme,
      textTheme: _textTheme(_darkScheme),
      scaffoldBackgroundColor: surfaceDark,
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF262626),
        thickness: 1,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme cs) {
    return TextTheme(
      headlineLarge: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: cs.onSurface, fontSize: 32, letterSpacing: -1),
      headlineMedium: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: cs.onSurface, fontSize: 24, letterSpacing: -0.5),
      titleLarge: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: cs.onSurface, fontSize: 20),
      titleMedium: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: cs.onSurface, fontSize: 17),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w400, color: cs.onSurface, fontSize: 16),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w400, color: cs.onSurfaceVariant, fontSize: 14),
      bodySmall: GoogleFonts.inter(fontWeight: FontWeight.w500, color: cs.onSurfaceVariant, fontSize: 12),
      labelMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: cs.primary, fontSize: 11, letterSpacing: 1.2),
    );
  }

  static TextStyle headingStyle(BuildContext context) => Theme.of(context).textTheme.headlineMedium!;
  static TextStyle bodyStyle(BuildContext context) => Theme.of(context).textTheme.bodyLarge!;
  static TextStyle captionStyle(BuildContext context) => Theme.of(context).textTheme.bodySmall!;
  static TextStyle labelStyle(BuildContext context) => Theme.of(context).textTheme.labelMedium!;
}
