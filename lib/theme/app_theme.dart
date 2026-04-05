import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Light Background
  static const Color darkBackground = Color(0xFFF7F5F9); // Lighter background
  static const Color surfaceDark = Color(0xFFFFFFFF); // White cards
  static const Color surfaceLight = Color(0xFFEBE5F0);

  static const Color goldPrimary = Color(0xFF4A3470); // Deep purple replacing Gold
  static const Color goldLight = Color(0xFF6B5196);
  static const Color goldDark = Color(0xFF332050);
  static const Color goldGlow = Color(0x404A3470);

  // Fire Gradient Colors (retained for compatibility if used)
  static const Color fireOrange = Color(0xFFFF9800);
  static const Color fireRedOrange = Color(0xFFFF5722);
  static const Color fireCrimson = Color(0xFFF44336);

  // Risk Level Colors (from mockup)
  static const Color riskLow = Color(0xFF4CAF50); // Green
  static const Color riskMedium = Color(0xFFFF9800); // Orange
  static const Color riskHigh = Color(0xFFF44336); // Red

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textGold = Color(0xFF4A3470);

  static const List<Color> fireGradient = [
    fireOrange,
    fireRedOrange,
    fireCrimson,
  ];

  static const List<Color> goldGradient = [
    goldDark,
    goldPrimary,
    goldLight,
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light, // Changed to light
      scaffoldBackgroundColor: darkBackground,
      primaryColor: goldPrimary,
      fontFamily: 'Roboto', // Default standard font
      colorScheme: const ColorScheme.light(
        primary: goldPrimary,
        secondary: goldLight,
        surface: surfaceDark,
        error: riskHigh,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: riskHigh, // Typically red as in the mockups
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: const BorderSide(color: goldPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
    );
  }

  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':
        return riskLow;
      case 'MEDIUM':
        return riskMedium;
      case 'HIGH':
        return riskHigh;
      default:
        return textSecondary;
    }
  }

  static Color getScoreColor(double score) {
    if (score >= 90) return riskLow;
    if (score >= 70) return riskMedium;
    return riskHigh;
  }
}
