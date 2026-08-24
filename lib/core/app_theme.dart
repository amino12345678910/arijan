import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Enhanced Colors
  static const Color emeraldPrimary = Color(0xFF0F4C3A); // Deep Emerald
  static const Color emeraldLight = Color(0xFF2E7D67);
  static const Color goldAccent = Color(0xFFD4AF37); // Metadata Gold
  static const Color goldLight = Color(0xFFF8E79B);
  
  static const Color darkBackground = Color(0xFF05110E); // Very dark green/black
  static const Color lightBackground = Color(0xFFFAFDFA);
  
  // Gradients
  static const LinearGradient mainGradient = LinearGradient(
    colors: [emeraldPrimary, Color(0xFF002B20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldLight, goldAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final TextTheme _textTheme = TextTheme(
      displayLarge: GoogleFonts.amiri(
        fontSize: 36,
        fontWeight: FontWeight.w900, // Extra Bold
        height: 1.4,
      ),
      displayMedium: GoogleFonts.amiri(
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: GoogleFonts.notoSansArabic( // Mix for numbers/modern look
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: emeraldPrimary,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.light(
        primary: emeraldPrimary,
        secondary: goldAccent,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      textTheme: _textTheme.apply(
        bodyColor: emeraldPrimary,
        displayColor: emeraldPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, // For gradient backgrounds
        foregroundColor: emeraldPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: emeraldPrimary,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: emeraldPrimary, // Keep green identity
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.dark(
        primary: emeraldLight, // Lighter for dark mode
        secondary: goldAccent,
        surface: const Color(0xFF0A261D), // Dark Green Surface
        onPrimary: Colors.white,
        onSecondary: Colors.black,
      ),
      textTheme: _textTheme.apply(
        bodyColor: Colors.white,
        displayColor: goldAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: goldAccent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.amiri(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: goldAccent,
        ),
      ),
    );
  }
}
