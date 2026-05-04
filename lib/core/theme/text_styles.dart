import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// WaveMart Text Styles
/// Using Lora for headings and Nunito for body text
/// Fonts are bundled locally - no network fetching required
class AppTextStyles {
  AppTextStyles._();

  static const String _headingFont = 'Lora';
  static const String _bodyFont = 'Nunito';

  // Headings
  static TextStyle get headline1 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1.0,
      );

  static TextStyle get headline2 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.8,
      );

  static TextStyle get headline3 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.5,
      );

  static TextStyle get headline4 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: -0.2,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get headline5 => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
      );

  static TextStyle get subtitle => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get bodyLargePlus => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.5,
      );

  static TextStyle get captionSmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.zinc600,
        height: 1.4,
      );

  // Body Text
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
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
        height: 1.5,
      );

  // Button Styles
  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  // Label Styles
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
        letterSpacing: 0.2,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
        letterSpacing: 0.2,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy600,
        letterSpacing: 0.5,
      );

  // Caption/Helper Text
  static TextStyle get caption => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.zinc600,
        height: 1.4,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy600,
        letterSpacing: 1.0,
      );

  // Price Display
  static TextStyle get priceLarge => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.emerald600,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get priceMedium => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.emerald600,
        height: 1.3,
        letterSpacing: -0.2,
      );

  // Badge/Pill Text
  static TextStyle get badge => const TextStyle(
        fontFamily: _headingFont,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      );

  // Navigation
  static TextStyle get navActive => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.wave600,
      );

  static TextStyle get navInactive => const TextStyle(
        fontFamily: _bodyFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.navy500,
      );

  // Helper method to create colored variants
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  static TextStyle withFocus(TextStyle base, bool isFocused) {
    return base.copyWith(
      fontWeight: isFocused ? FontWeight.w700 : base.fontWeight,
    );
  }
}

