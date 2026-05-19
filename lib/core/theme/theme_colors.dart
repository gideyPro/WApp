import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ThemeColors {
  final BuildContext context;
  ThemeColors(this.context);

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  // Background colors
  Color get scaffold => isDark ? const Color(0xFF080C14) : AppColors.stone100;
  Color get surface => isDark ? AppColors.primary800 : Colors.white;
  Color get card => isDark ? AppColors.primary800 : Colors.white;
  Color get cardBg => isDark ? AppColors.primary800 : Colors.white;
  Color get cardBgElevated => isDark ? const Color(0xFF1E293B) : Colors.white;

  // Text colors
  Color get textPrimary => isDark ? Colors.white : AppColors.stone900;
  Color get textSecondary => isDark ? AppColors.primary200 : AppColors.stone800;
  Color get textTertiary => isDark ? AppColors.primary300 : AppColors.stone700;
  Color get textMuted => isDark ? AppColors.primary400 : AppColors.stone600;

  // Icon colors
  Color get icon => isDark ? Colors.white : AppColors.primary900;
  Color get iconSecondary => isDark ? AppColors.primary300 : AppColors.stone600;

  // Border colors
  Color get border => isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.stone300;
  Color get divider => isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.stone200;

  // Input colors
  Color get inputBg => isDark ? AppColors.primary800 : Colors.white;
  Color get inputBorder => isDark ? Colors.white.withValues(alpha: 0.12) : AppColors.stone300;

  // Button colors
  Color get primary => isDark ? AppColors.accent500 : AppColors.primary900;
  Color get primaryText => isDark ? Colors.black : Colors.white;

  // Icon button backgrounds
  Color get iconBg => isDark ? AppColors.primary700 : AppColors.stone200;

  // Shimmer colors
  Color get shimmerBase => isDark ? AppColors.primary700 : AppColors.stone200;
  Color get shimmerHighlight => isDark ? AppColors.primary800 : AppColors.stone100;

  // Sheet/Bottom nav
  Color get bottomSheet => isDark ? AppColors.primary800 : Colors.white;
  Color get bottomNav => isDark ? AppColors.primary800 : Colors.white;
}

// Quick access extension
extension ThemeColorsExtension on BuildContext {
  ThemeColors get theme => ThemeColors(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // Legacy compatibility getters (mapped to ThemeColors)
  Color get scaffoldBg => theme.scaffold;
  Color get cardBg => theme.card;
  Color get cardBgElevated => theme.cardBgElevated;
  Color get textPrimary => theme.textPrimary;
  Color get textSecondary => theme.textSecondary;
  Color get textMuted => theme.textMuted;
  Color get iconPrimary => theme.icon;
  Color get divider => theme.divider;
  Color get inputBg => theme.inputBg;
  Color get sheetBg => theme.bottomSheet;
  Color get shimmerBase => theme.shimmerBase;
  Color get shimmerHighlight => theme.shimmerHighlight;

  // Glassmorphism helpers
  Color get glassBg => isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7);
  Color get glassBorder => isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8);
}
