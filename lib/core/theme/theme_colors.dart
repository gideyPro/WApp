import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeColors {
  final BuildContext context;
  ThemeColors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // Background colors
  Color get scaffold => isDark ? AppColors.primary900 : AppColors.primary50;
  Color get surface => isDark ? AppColors.primary800 : Colors.white;
  Color get card => isDark ? AppColors.primary800 : Colors.white;
  Color get cardBg => isDark ? AppColors.primary800 : Colors.white;

  // Text colors
  Color get textPrimary => isDark ? Colors.white : AppColors.primary800;
  Color get textSecondary => isDark ? AppColors.primary200 : AppColors.primary600;
  Color get textTertiary => isDark ? AppColors.primary300 : AppColors.primary500;
  Color get textMuted => isDark ? AppColors.primary400 : AppColors.primary500;

  // Icon colors
  Color get icon => isDark ? Colors.white : AppColors.primary700;
  Color get iconSecondary => isDark ? AppColors.primary300 : AppColors.primary500;

  // Border colors
  Color get border => isDark ? AppColors.primary700 : AppColors.primary200;
  Color get divider => isDark ? AppColors.primary700 : AppColors.primary200;

  // Input colors
  Color get inputBg => isDark
      ? AppColors.primary800
      : AppColors.primary50.withValues(alpha: 0.5);
  Color get inputBorder => isDark ? AppColors.primary700 : AppColors.primary300;

  // Button colors
  Color get primary => isDark ? AppColors.accent500 : AppColors.primary600;
  Color get primaryText => Colors.white;

  // Icon button backgrounds
  Color get iconBg => isDark ? AppColors.primary800 : AppColors.primary100;

  // Shimmer colors
  Color get shimmerBase => isDark ? AppColors.primary800 : Colors.grey[300]!;
  Color get shimmerHighlight => isDark ? AppColors.primary700 : Colors.grey[100]!;

  // Sheet/Bottom nav
  Color get bottomSheet => isDark ? AppColors.primary800 : Colors.white;
  Color get bottomNav => isDark ? AppColors.primary900 : Colors.white;
}

// Quick access extension
extension ThemeColorsExtension on BuildContext {
  ThemeColors get theme => ThemeColors(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
