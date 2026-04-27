import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeColors {
  final BuildContext context;
  ThemeColors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // Background colors
  Color get scaffold => isDark ? AppColors.navy950 : AppColors.zinc50;
  Color get surface => isDark ? AppColors.navy900 : Colors.white;
  Color get card => isDark ? AppColors.navy900 : Colors.white;
  Color get cardBg => isDark ? AppColors.navy900 : Colors.white;
  Color get wave50 => isDark ? AppColors.wave900 : AppColors.wave50;

  // Text colors
  Color get textPrimary => isDark ? Colors.white : AppColors.zinc900;
  Color get textSecondary => isDark ? AppColors.zinc300 : AppColors.zinc600;
  Color get textTertiary => isDark ? AppColors.zinc400 : AppColors.navy400;
  Color get textMuted => isDark ? AppColors.navy400 : AppColors.zinc400;

  // Icon colors
  Color get icon => isDark ? Colors.white : AppColors.navy700;
  Color get iconSecondary => isDark ? AppColors.navy300 : AppColors.navy500;

  // Border colors
  Color get border => isDark ? AppColors.navy800 : AppColors.zinc200;
  Color get divider => isDark ? AppColors.navy800 : AppColors.zinc200;

  // Input colors
  Color get inputBg => isDark 
      ? AppColors.navy900 
      : AppColors.zinc50.withValues(alpha: 0.5);
  Color get inputBorder => isDark ? AppColors.navy700 : AppColors.zinc300;

  // Button colors
  Color get primary => isDark ? AppColors.wave500 : AppColors.navy950;
  Color get primaryText => Colors.white;

  // Icon button backgrounds
  Color get iconBg => isDark ? AppColors.navy800 : AppColors.zinc100;

  // Shimmer colors
  Color get shimmerBase => isDark ? AppColors.navy800 : Colors.grey[300]!;
  Color get shimmerHighlight => isDark ? AppColors.navy700 : Colors.grey[100]!;

  // Sheet/Bottom nav
  Color get bottomSheet => isDark ? AppColors.navy900 : Colors.white;
  Color get bottomNav => isDark ? AppColors.navy900 : Colors.white;
}

// Quick access extension
extension ThemeColorsExtension on BuildContext {
  ThemeColors get theme => ThemeColors(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}