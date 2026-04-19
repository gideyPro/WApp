import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// WaveMart Text Styles
/// Using Outfit for headings and Inter for body text
/// Fonts are bundled locally - no network fetching required
class AppTextStyles {
  AppTextStyles._();

  // Headings - Outfit Font
  static TextStyle get headline1 => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.navy950,
        height: 1.1,
        letterSpacing: -0.5,
      );

  static TextStyle get headline2 => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.navy950,
        height: 1.2,
        letterSpacing: -0.3,
      );

  static TextStyle get headline3 => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.navy950,
        height: 1.25,
      );

  static TextStyle get headline4 => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.navy950,
        height: 1.3,
      );

  static TextStyle get title => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.navy950,
        height: 1.35,
      );

  static TextStyle get titleSmall => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.navy950,
        height: 1.4,
      );

  // Body Text - System Default
  static TextStyle get bodyLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.zinc700,
        height: 1.5,
      );

  static TextStyle get bodyMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.zinc600,
        height: 1.5,
      );

  static TextStyle get bodySmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.zinc500,
        height: 1.5,
      );

  // Button Styles
  static TextStyle get buttonLarge => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonMedium => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonSmall => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.8,
      );

  // Label Styles
  static TextStyle get labelLarge => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.navy700,
        letterSpacing: 0.8,
      );

  static TextStyle get labelSmall => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy600,
        letterSpacing: 1.2,
      );

  // Caption/Helper Text
  static TextStyle get caption => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.zinc500,
        height: 1.4,
      );

  static TextStyle get overline => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.navy600,
        letterSpacing: 1.5,
      );

  // Price Display
  static TextStyle get priceLarge => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.emerald600,
        height: 1.2,
      );

  static TextStyle get priceMedium => const TextStyle(
        fontFamily: 'Outfit',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.emerald600,
        height: 1.3,
      );

  // Badge/Pill Text
  static TextStyle get badge => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      );

  // Navigation
  static TextStyle get navActive => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.wave600,
      );

  static TextStyle get navInactive => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.navy500,
      );

  // Helper method to create colored variants
  static TextStyle withColor(TextStyle base, Color color) {
    return base.copyWith(color: color);
  }

  static TextStyle withSize(TextStyle base, double size) {
    return base.copyWith(fontSize: size);
  }

  static TextStyle bold(TextStyle base) {
    return base.copyWith(fontWeight: FontWeight.bold);
  }
}
