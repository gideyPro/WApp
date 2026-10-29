import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Wavemart Text Styles — Plus Jakarta Sans across all marketplace headings, body, labels, buttons, and captions.
class AppTextStyles {
  AppTextStyles._();

  static const String primaryFont = 'PlusJakartaSans';
  static const List<String> fontFallback = ['NotoSansEthiopic'];

  // Backward compatibility alias
  static const String headingFont = primaryFont;
  static const List<String> headingFallback = fontFallback;

  static TextStyle get headline1 => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0.0,
      );

  static TextStyle get headline2 => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.28,
        letterSpacing: 0.0,
      );

  static TextStyle get headline3 => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
      );

  static TextStyle get headline4 => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.1,
      );

  static TextStyle get headline5 => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.1,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.35,
        letterSpacing: 0.15,
      );

  // Eyebrow label — no hardcoded color; inherits from theme
  static TextStyle get eyebrow => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: AppColors.primary900,
      );

  static TextStyle get subtitle => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.15,
      );

  static TextStyle get bodyLargePlus => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.45,
        letterSpacing: 0.15,
      );

  // Body Text — calibrated to w500 + positive tracking to prevent dense Ge'ez loops from clogging
  static TextStyle get bodyLarge => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.55,
        letterSpacing: 0.2,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.2,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.2,
      );

  // Button Styles
  static TextStyle get buttonLarge => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.35,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.35,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.35,
      );

  // Label Styles — calibrated to w700 (avoids w900 which crushes Ethiopic counters)
  static TextStyle get labelLarge => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.primary800,
        letterSpacing: 0.25,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.primary800,
        letterSpacing: 0.25,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primary700,
        letterSpacing: 0.35,
      );

  // Caption/Helper Text
  static TextStyle get caption => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.stone700,
        height: 1.4,
        letterSpacing: 0.25,
      );

  static TextStyle get overline => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.primary700,
        letterSpacing: 2.0,
      );

  // Price Display — non-negative tracking so Ge'ez currency and labels do not collide
  static TextStyle get priceLarge => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.emerald600,
        height: 1.2,
        letterSpacing: 0.0,
      );

  static TextStyle get priceMedium => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.emerald600,
        height: 1.25,
        letterSpacing: 0.0,
      );

  // Badge/Pill Text
  static TextStyle get badge => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  // Navigation
  static TextStyle get navActive => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.accent500,
        letterSpacing: 0.15,
      );

  static TextStyle get navInactive => const TextStyle(
        fontFamily: primaryFont,
        fontFamilyFallback: fontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary600,
        letterSpacing: 0.15,
      );

  /// Returns a copy of [base] with extra breathing room for Ethiopic text.
  static TextStyle ethiopic(TextStyle base) {
    return base.copyWith(
      letterSpacing: (base.letterSpacing ?? 0.0) < 0.25 ? 0.35 : (base.letterSpacing! + 0.1),
      height: (base.height ?? 1.3) < 1.4 ? 1.45 : base.height,
    );
  }

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

extension EthiopicTextStyleExtension on TextStyle {
  /// Adds optimal letter spacing and line height breathing room for Ge'ez/Ethiopic script.
  TextStyle get ethiopic => AppTextStyles.ethiopic(this);
}
