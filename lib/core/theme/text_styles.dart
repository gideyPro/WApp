import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// WaveMart Text Styles — Cinzel for headings, Montserrat for body (min w500).
class AppTextStyles {
  AppTextStyles._();

  static const String _headingFont = 'Cinzel';
  static const String _bodyFont = 'Montserrat';
  static TextStyle get headline1 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get headline2 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
      );

  static TextStyle get headline3 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  static TextStyle get headline4 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headline5 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: 0.1,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  // Eyebrow label — no hardcoded color; inherits from theme
  static TextStyle get eyebrow => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: AppColors.primary900,
      );

  static TextStyle get subtitle => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get bodyLargePlus => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Body Text
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.1,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // Button Styles
  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 15,
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

  // Label Styles — no hardcoded color; inherits from theme's onSurface
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.primary800,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary800,
        letterSpacing: 0.1,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.primary700,
        letterSpacing: 0.3,
      );

  // Caption/Helper Text — no hardcoded color; inherits from theme's onSurface
  static TextStyle get caption => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.stone700,
        height: 1.3,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primary700,
        letterSpacing: 2.0,
      );

  // Price Display
  static TextStyle get priceLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.primary900,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get priceMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary800,
        height: 1.2,
      );

  // Badge/Pill Text
  static TextStyle get badge => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  // Navigation
  static TextStyle get navActive => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.accent500,
      );

  static TextStyle get navInactive => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary600,
      );

  // Helper method to create colored variants
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  static TextStyle withFocus(TextStyle base, bool isFocused) {
    return base.copyWith(
      fontWeight: isFocused ? FontWeight.w800 : base.fontWeight,
    );
  }
}
