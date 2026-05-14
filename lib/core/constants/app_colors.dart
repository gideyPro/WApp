import 'package:flutter/material.dart';

/// WaveMart Brand Colors
/// Based on the web application's Tailwind CSS color palette
class AppColors {
  AppColors._();

  // Primary Brand - Teal (from web: #0F766E)
  static const Color primary50 = Color(0xFFF0FDFA);
  static const Color primary100 = Color(0xFFCCFBF1);
  static const Color primary200 = Color(0xFF99F6E4);
  static const Color primary300 = Color(0xFF5EEAD4);
  static const Color primary400 = Color(0xFF2DD4BF);
  static const Color primary500 = Color(0xFF14B8A6);
  static const Color primary600 = Color(0xFF0F766E);
  static const Color primary700 = Color(0xFF115E59);
  static const Color primary800 = Color(0xFF134E4A);
  static const Color primary900 = Color(0xFF042F2E);

  // Deprecated aliases (for migration compatibility, remove later)
  static const Color navy50 = primary50;
  static const Color navy100 = primary100;
  static const Color navy200 = primary200;
  static const Color navy300 = primary300;
  static const Color navy400 = primary400;
  static const Color navy500 = primary500;
  static const Color navy600 = primary600;
  static const Color navy700 = primary700;
  static const Color navy800 = primary800;
  static const Color navy900 = primary900;
  static const Color navy950 = primary900;

  // Accent - Emerald (matches web: #059669)
  static const Color accent50 = Color(0xFFecfdf5);
  static const Color accent100 = Color(0xFFd1fae5);
  static const Color accent200 = Color(0xFFa7f3d0);
  static const Color accent300 = Color(0xFF6ee7b7);
  static const Color accent400 = Color(0xFF34d399);
  static const Color accent500 = Color(0xFF10b981);
  static const Color accent600 = Color(0xFF059669);
  static const Color accent700 = Color(0xFF047857);
  static const Color accent800 = Color(0xFF065f46);
  static const Color accent900 = Color(0xFF064e3b);
  static const Color accent950 = Color(0xFF022c22);

  // Deprecated aliases (for migration compatibility, remove later)
  static const Color wave50 = accent50;
  static const Color wave100 = accent100;
  static const Color wave200 = accent200;
  static const Color wave300 = accent300;
  static const Color wave400 = accent400;
  static const Color wave500 = accent500;
  static const Color wave600 = accent600;
  static const Color wave700 = accent700;
  static const Color wave800 = accent800;
  static const Color wave900 = accent900;
  static const Color wave950 = accent950;

  // CTA Blue (matches web: #0369A1)
  static const Color cta50 = Color(0xFFF0F9FF);
  static const Color cta100 = Color(0xFFE0F2FE);
  static const Color cta200 = Color(0xFFBAE6FD);
  static const Color cta300 = Color(0xFF7DD3FC);
  static const Color cta400 = Color(0xFF38BDF8);
  static const Color cta500 = Color(0xFF0EA5E9);
  static const Color cta600 = Color(0xFF0284C7);
  static const Color cta700 = Color(0xFF0369A1);
  static const Color cta800 = Color(0xFF075985);
  static const Color cta900 = Color(0xFF0C4A6E);
  static const Color cta950 = Color(0xFF082f49);

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
  static const Color background = primary50;
  static const Color surface = Colors.white;
  static const Color surfaceVariant = primary50;

  // Gradient Definitions
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary600, primary700],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientAccent = LinearGradient(
    colors: [accent500, accent600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientCta = LinearGradient(
    colors: [cta700, cta600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientEmerald = LinearGradient(
    colors: [emerald500, emerald600],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientHero = LinearGradient(
    colors: [primary900, primary800],
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
          color: primary700.withValues(alpha: 0.10),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: primary700.withValues(alpha: 0.18),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: primary700.withValues(alpha: 0.22),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get shadowAccent => [
        BoxShadow(
          color: accent600.withValues(alpha: 0.30),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
          color: accent600.withValues(alpha: 0.40),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];

  // Premium Shadows
  static List<BoxShadow> get shadowPremium => [
        BoxShadow(
          color: primary700.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: primary700.withValues(alpha: 0.06),
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

  Color get scaffoldBg => isDarkMode ? AppColors.primary900 : AppColors.primary50;
  Color get cardBg => isDarkMode ? AppColors.primary800 : Colors.white;
  Color get cardBgElevated => isDarkMode ? AppColors.navy950 : Colors.white;
  Color get textPrimary => isDarkMode ? Colors.white : AppColors.primary800;
  Color get textSecondary => isDarkMode ? AppColors.primary200 : AppColors.primary600;
  Color get textMuted => isDarkMode ? AppColors.primary300 : AppColors.primary500;
  Color get iconPrimary => isDarkMode ? Colors.white : AppColors.primary700;
  Color get divider => isDarkMode ? AppColors.primary700 : AppColors.primary200;
  Color get inputBg => isDarkMode ? AppColors.primary800 : AppColors.primary50.withOpacity(0.5);
  Color get sheetBg => isDarkMode ? AppColors.primary800 : Colors.white;
  Color get shimmerBase => isDarkMode ? AppColors.navy950 : Colors.grey[300]!;
  Color get shimmerHighlight => isDarkMode ? AppColors.primary700 : Colors.grey[100]!;

  // Glassmorphism helpers
  Color get glassBg => isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.7);
  Color get glassBorder => isDarkMode ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8);
}
