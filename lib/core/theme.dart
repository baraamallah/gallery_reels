import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color tokens
  static const Color accentColor = Color(0xFFB392F0); // soft violet — primary
  static const Color deleteColor = Color(0xFFFF6B6B); // soft red
  static const Color keepColor = Color(0xFF4ADE80); // soft green
  static const Color tagColor = Color(0xFF60a5fa); // soft blue
  static const Color shareColor = Color(0xFFc084fc); // soft purple

  // Background gradient
  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0B0B12), Color(0xFF160F24), Color(0xFF0A111F)],
    ),
  );

  // Typography
  static TextStyle headingStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle bodyStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    color: const Color(0xFFBFBFBF),
  );

  static TextStyle captionStyle = GoogleFonts.inter(
    fontWeight: FontWeight.w400,
    color: const Color(0xFF737373),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accentColor,
    scaffoldBackgroundColor: Colors.transparent, // We use gradient background
    textTheme: TextTheme(
      headlineMedium: headingStyle.copyWith(fontSize: 24),
      bodyLarge: bodyStyle.copyWith(fontSize: 16),
      bodySmall: captionStyle.copyWith(fontSize: 12),
    ),
    colorScheme: const ColorScheme.dark(
      primary: accentColor,
      secondary: accentColor,
      surface: Color(0xFF1a1030),
      error: deleteColor,
    ),
  );
}
