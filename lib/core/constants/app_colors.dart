import 'package:flutter/material.dart';

/// WaveMart Brand Colors
/// Based on the web application's Tailwind CSS color palette
class AppColors {
  AppColors._();

  // Primary Brand - Navy (Deep Blue from logo)
  static const Color navy50 = Color(0xFFf0f4f8);
  static const Color navy100 = Color(0xFFd9e2ec);
  static const Color navy200 = Color(0xFFbcccdc);
  static const Color navy300 = Color(0xFF9fb3c8);
  static const Color navy400 = Color(0xFF829ab1);
  static const Color navy500 = Color(0xFF627d98);
  static const Color navy600 = Color(0xFF486581);
  static const Color navy700 = Color(0xFF334e68);
  static const Color navy800 = Color(0xFF243b53);
  static const Color navy900 = Color(0xFF1e3a5f);
  static const Color navy950 = Color(0xFF102a43);

  // Primary Accent - Wave (Vibrant Green based on backend config)
  static const Color wave50 = Color(0xFFedfcf2);
  static const Color wave100 = Color(0xFFd3f9e0);
  static const Color wave200 = Color(0xFFaaf0c4);
  static const Color wave300 = Color(0xFF73e2a3);
  static const Color wave400 = Color(0xFF3acd7e);
  static const Color wave500 = Color(0xFF16b364);
  static const Color wave600 = Color(0xFF0d9450);
  static const Color wave700 = Color(0xFF0b7742);
  static const Color wave800 = Color(0xFF0c5e37);
  static const Color wave900 = Color(0xFF0a4d2e);
  static const Color wave950 = Color(0xFF052b19);

  // Success - Emerald
  static const Color emerald50 = Color(0xFFecfdf5);
  static const Color emerald100 = Color(0xFFd1fae5);
  static const Color emerald200 = Color(0xFFa7f3d0);
  static const Color emerald300 = Color(0xFF6ee7b7);
  static const Color emerald400 = Color(0xFF34d399);
  static const Color emerald500 = Color(0xFF10b981);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald800 = Color(0xFF065f46);
  static const Color emerald900 = Color(0xFF064e3b);

  // Neutrals - Zinc (Warm grays)
  static const Color zinc50 = Color(0xFFfafaf9);
  static const Color zinc100 = Color(0xFFf5f5f4);
  static const Color zinc200 = Color(0xFFe7e5e4);
  static const Color zinc300 = Color(0xFFd6d3d1);
  static const Color zinc400 = Color(0xFFa8a29e);
  static const Color zinc500 = Color(0xFF78716c);
  static const Color zinc600 = Color(0xFF57534e);
  static const Color zinc700 = Color(0xFF44403c);
  static const Color zinc800 = Color(0xFF292524);
  static const Color zinc900 = Color(0xFF1c1917);

  // Semantic Colors
  static const Color error = Color(0xFFdc2626);
  static const Color errorLight = Color(0xFFfee2e2);
  static const Color warning = Color(0xFFf59e0b);
  static const Color warningLight = Color(0xFFfef3c7);
  static const Color success = Color(0xFF10b981);
  static const Color successLight = Color(0xFFd1fae5);
  static const Color info = Color(0xFF3b82f6);
  static const Color infoLight = Color(0xFFdbeafe);

  // Background Colors
  static const Color background = zinc50;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = zinc100;

  // Gradient Definitions
  static const LinearGradient gradientNavy = LinearGradient(
    colors: [navy900, navy950],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientWave = LinearGradient(
    colors: [wave500, wave600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientEmerald = LinearGradient(
    colors: [emerald500, emerald600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientHero = LinearGradient(
    colors: [navy950, navy900],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientError = LinearGradient(
    colors: [Color(0xFFef4444), Color(0xFFdc2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientWarning = LinearGradient(
    colors: [Color(0xFFf59e0b), Color(0xFFd97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientInfo = LinearGradient(
    colors: [Color(0xFF3b82f6), Color(0xFF2563eb)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientNetwork = LinearGradient(
    colors: [zinc500, zinc600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Definitions
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: navy950.withOpacity(0.08),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: navy950.withOpacity(0.12),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: navy950.withOpacity(0.16),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowWave => [
        BoxShadow(
          color: wave600.withOpacity(0.22),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
          color: wave600.withOpacity(0.35),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ];

  // Premium Premium Shadows
  static List<BoxShadow> get shadowPremium => [
        BoxShadow(
          color: navy950.withOpacity(0.04),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: navy950.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> shadowDarkPremium(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: -5,
        ),
      ];
}

/// Theme-aware extension for easy dark mode support
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDarkMode ? AppColors.navy950 : AppColors.zinc50;
  Color get cardBg => isDarkMode ? AppColors.navy900 : Colors.white;
  Color get cardBgElevated => isDarkMode ? AppColors.navy800 : Colors.white;
  Color get textPrimary => isDarkMode ? Colors.white : AppColors.zinc900;
  Color get textSecondary => isDarkMode ? AppColors.zinc300 : AppColors.zinc700;
  Color get textMuted => isDarkMode ? AppColors.navy400 : AppColors.zinc500;
  Color get iconPrimary => isDarkMode ? Colors.white : AppColors.navy700;
  Color get divider => isDarkMode ? AppColors.navy800 : AppColors.zinc200;
  Color get inputBg => isDarkMode ? AppColors.navy900 : AppColors.zinc50.withOpacity(0.5);
  Color get sheetBg => isDarkMode ? AppColors.navy900 : Colors.white;
  Color get shimmerBase => isDarkMode ? AppColors.navy800 : Colors.grey[300]!;
  Color get shimmerHighlight => isDarkMode ? AppColors.navy700 : Colors.grey[100]!;
  
  // Glassmorphism helpers
  Color get glassBg => isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7);
  Color get glassBorder => isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.2);
}