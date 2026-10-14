import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// DealLens Design System — premium light-theme shopping aggregator.
class DealLensTheme {
  DealLensTheme._();

  // ── Primary Palette ──────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color primaryBlueLight = Color(0xFF42A5F5);
  static const Color primaryBlueDark = Color(0xFF0D47A1);

  // ── Savings / Price ──────────────────────────────────────────────
  static const Color savingsGreen = Color(0xFF2E7D32);
  static const Color savingsGreenLight = Color(0xFFE8F5E9);

  // ── Surfaces ─────────────────────────────────────────────────────
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF1F3F5);
  static const Color borderSubtle = Color(0xFFE0E0E0);

  // ── Text ─────────────────────────────────────────────────────────
  static const Color textNavy = Color(0xFF1A2138);
  static const Color textSecondary = Color(0xFF5F6B7A);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Feedback ─────────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF9A825);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgWhite,
      primaryColor: primaryBlue,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        onPrimary: textOnPrimary,
        primaryContainer: Color(0xFFD1E4FF),
        secondary: savingsGreen,
        onSecondary: textOnPrimary,
        surface: surfaceCard,
        onSurface: textNavy,
        surfaceContainerHighest: surfaceGrey,
        error: error,
        onError: textOnPrimary,
        outline: borderSubtle,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textNavy,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          color: textNavy,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        headlineMedium: GoogleFonts.outfit(
          color: textNavy,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textNavy,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          color: textNavy,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textNavy,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          color: textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.inter(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textNavy,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: textNavy),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderSubtle, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.inter(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceGrey,
        selectedColor: const Color(0xFFD1E4FF),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textNavy,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: const BorderSide(color: borderSubtle, width: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: bgWhite,
        selectedItemColor: primaryBlue,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 0.8,
        space: 0,
      ),
      iconTheme: const IconThemeData(color: textSecondary, size: 22),
    );
  }
}
