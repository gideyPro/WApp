import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// WaveMart Text Styles
/// Using Cinzel for headings and Montserrat for body text
/// Fonts are bundled locally - no network fetching required
class AppTextStyles {
  AppTextStyles._();

  static const String _headingFont = 'Cinzel';
  static const String _bodyFont = 'Montserrat';

  // Headings - Using Cinzel sparingly for premium drama
  static TextStyle get headline1 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 40, // Slightly reduced for mobile elegance
        fontWeight: FontWeight.w800, // Bolder for luxury authority
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get headline2 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get headline3 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 26,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle get headline4 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle get headline5 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        height: 1.4,
        letterSpacing: 0.2,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.4,
      );

  // Eyebrow label - Pure luxury (Spaced out)
  static TextStyle get eyebrow => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 4.0, // High spacing for luxury feel
        color: AppColors.primary900,
      );

  static TextStyle get subtitle => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.4,
      );

  static TextStyle get bodyLargePlus => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // Body Text - Montserrat for clean legibility
  // Weight increased to Semi-Bold (w600) for better visibility on mobile
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.6,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.6,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  // Button Styles
  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  // Label Styles
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary800,
        letterSpacing: 0.2,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary800,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primary700, // Darkened for legibility
        letterSpacing: 0.5,
      );

  // Caption/Helper Text
  static TextStyle get caption => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.stone700, // Darkened from stone600 for better contrast
        height: 1.4,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: AppColors.primary700,
        letterSpacing: 3.0,
      );

  // Price Display - Shifting to Montserrat for Trust & Clarity
  static TextStyle get priceLarge => const TextStyle(
        fontFamily: _bodyFont, 
        fontSize: 24,
        fontWeight: FontWeight.w900, // Ultra-Bold for financial authority
        color: AppColors.primary900,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get priceMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.primary800,
        height: 1.3,
      );

  // Badge/Pill Text
  static TextStyle get badge => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      );

  // Navigation
  static TextStyle get navActive => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.accent500,
      );

  static TextStyle get navInactive => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary600, // Darkened from primary500
      );

  // Helper method to create colored variants
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  static TextStyle withFocus(TextStyle base, bool isFocused) {
    return base.copyWith(
      fontWeight: isFocused ? FontWeight.w900 : base.fontWeight,
    );
  }
}
