import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color textPrimary, Color textSecondary) {
    final baseFont = GoogleFonts.interTextTheme();

    return baseFont.copyWith(
      displayLarge: GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        letterSpacing: -0.02,
        color: textPrimary,
      ),
      headlineLarge: GoogleFonts.manrope(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 34 / 26,
        letterSpacing: -0.015,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
        letterSpacing: -0.01,
        color: textPrimary,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 24 / 18,
        letterSpacing: -0.005,
        color: textPrimary,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        letterSpacing: 0,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 18 / 13,
        letterSpacing: 0.005,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 18 / 14,
        letterSpacing: 0.01,
        color: textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 16 / 13,
        letterSpacing: 0.01,
        color: textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 14 / 11,
        letterSpacing: 0.02,
        color: textSecondary,
      ),
    );
  }
}
