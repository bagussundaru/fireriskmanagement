import 'package:flutter/material.dart';

class AppTheme {
  // ─── Dark Premium Color Palette ───────────────────────────────────────────
  static const Color darkBackground   = Color(0xFF0D0F1A); // Deep navy-dark
  static const Color surfaceDark      = Color(0xFF151829); // Card surface
  static const Color surfaceElevated  = Color(0xFF1E2235); // Elevated surface
  static const Color surfaceLight     = Color(0xFF252840); // Input/track bg

  // ─── Brand / Gold ─────────────────────────────────────────────────────────
  static const Color goldPrimary  = Color(0xFFFF6B35); // Vibrant fire-orange
  static const Color goldLight    = Color(0xFFFF9A6C);
  static const Color goldDark     = Color(0xFFCC4A1A);
  static const Color goldGlow     = Color(0x40FF6B35);

  // ─── Accent ───────────────────────────────────────────────────────────────
  static const Color accentBlue   = Color(0xFF4FC3F7);
  static const Color accentPurple = Color(0xFF9C6FDE);

  // ─── Risk ─────────────────────────────────────────────────────────────────
  static const Color riskLow    = Color(0xFF00C897); // Emerald green
  static const Color riskMedium = Color(0xFFFFAB00); // Amber
  static const Color riskHigh   = Color(0xFFFF3B5C); // Vivid red

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF8890B5);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient fireGradient = LinearGradient(
    colors: [Color(0xFFFF3B5C), Color(0xFFFF6B35), Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D0F1A), Color(0xFF1A1030), Color(0xFF0D0F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E2235), Color(0xFF151829)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Theme Data ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: goldPrimary,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        secondary: accentBlue,
        surface: surfaceDark,
        error: riskHigh,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: const BorderSide(color: goldPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: goldPrimary, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static Color getRiskColor(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':    return riskLow;
      case 'MEDIUM': return riskMedium;
      case 'HIGH':   return riskHigh;
      default:       return textSecondary;
    }
  }

  static Color getScoreColor(double score) {
    if (score >= 90) return riskLow;
    if (score >= 70) return riskMedium;
    return riskHigh;
  }

  static List<Color> getRiskGradient(String riskLevel) {
    switch (riskLevel.toUpperCase()) {
      case 'LOW':    return [const Color(0xFF00C897), const Color(0xFF00A878)];
      case 'MEDIUM': return [const Color(0xFFFFAB00), const Color(0xFFFF8C00)];
      case 'HIGH':   return [const Color(0xFFFF3B5C), const Color(0xFFCC1A3A)];
      default:       return [textSecondary, textSecondary];
    }
  }
}
