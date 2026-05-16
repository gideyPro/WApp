import 'package:flutter/material.dart';

/// WaveMart Brand Colors
/// Logo-Matched Palette: Navy (#0A416B) & Emerald (#16B364)
class AppColors {
  AppColors._();

  // Primary Brand - Logo Navy
  static const Color primary50 = Color(0xFFF1F5F9);
  static const Color primary100 = Color(0xFFE2E8F0);
  static const Color primary200 = Color(0xFFCBD5E1);
  static const Color primary300 = Color(0xFF94A3B8);
  static const Color primary400 = Color(0xFF64748B);
  static const Color primary500 = Color(0xFF475569);
  static const Color primary600 = Color(0xFF334155);
  static const Color primary700 = Color(0xFF1E293B);
  static const Color primary800 = Color(0xFF0F172A);
  static const Color primary900 = Color(0xFF0A416B); // Core Logo Navy
  static const Color primary950 = Color(0xFF073254);

  // Deprecated aliases for compatibility
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
  static const Color navy950 = primary950;

  // Accent - Logo Emerald
  static const Color accent50 = Color(0xFFECFDF5);
  static const Color accent100 = Color(0xFFD1FAE5);
  static const Color accent200 = Color(0xFFA7F3D0);
  static const Color accent300 = Color(0xFF6EE7B7);
  static const Color accent400 = Color(0xFF34D399);
  static const Color accent500 = Color(0xFF16B364); // Core Logo Emerald
  static const Color accent600 = Color(0xFF10B981);
  static const Color accent700 = Color(0xFF059669);
  static const Color accent800 = Color(0xFF047857);
  static const Color accent900 = Color(0xFF064E3B);
  static const Color accent950 = Color(0xFF052B19);

  // Deprecated aliases for compatibility
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

  // CTA Blue
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

  // Success (Mapped to Logo Emerald)
  static const Color emerald50 = accent50;
  static const Color emerald100 = accent100;
  static const Color emerald200 = accent200;
  static const Color emerald300 = accent300;
  static const Color emerald400 = accent400;
  static const Color emerald500 = accent500;
  static const Color emerald600 = accent600;
  static const Color emerald700 = accent700;
  static const Color emerald800 = accent800;
  static const Color emerald900 = accent900;

  // Neutrals - Stone/Slate for better contrast with Navy
  static const Color stone50 = Color(0xFFF8FAFC);
  static const Color stone100 = Color(0xFFF1F5F9);
  static const Color stone200 = Color(0xFFE2E8F0);
  static const Color stone300 = Color(0xFFCBD5E1);
  static const Color stone400 = Color(0xFF94A3B8);
  static const Color stone500 = Color(0xFF64748B);
  static const Color stone600 = Color(0xFF475569);
  static const Color stone700 = Color(0xFF334155);
  static const Color stone800 = Color(0xFF1E293B);
  static const Color stone900 = Color(0xFF0F172A);

  // Backward compatibility for Zinc (Aliases)
  static const Color zinc50 = stone50;
  static const Color zinc100 = stone100;
  static const Color zinc200 = stone200;
  static const Color zinc300 = stone300;
  static const Color zinc400 = stone400;
  static const Color zinc500 = stone500;
  static const Color zinc600 = stone600;
  static const Color zinc700 = stone700;
  static const Color zinc800 = stone800;
  static const Color zinc900 = stone900;

  // Semantic Colors
  static const Color error = Color(0xFF991B1B);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFF92400E);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color success = Color(0xFF065F46);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color info = Color(0xFF1E3A8A);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Background Colors - Cool Slate White
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Gradient Definitions
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [primary900, Color(0xFF1E293B)],
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
    colors: [primary900, Color(0xFF0F172A)],
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
    colors: [stone500, stone600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Definitions - "Quiet Luxury" Ambient Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: primary900.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: primary900.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: primary900.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowPremium => [
        BoxShadow(
          color: primary900.withValues(alpha: 0.06),
          blurRadius: 40,
          offset: const Offset(0, 20),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> shadowDarkPremium(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: -5,
        ),
      ];
}

/// Theme-aware extension for easy dark mode support
extension AppColorsExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDarkMode ? const Color(0xFF080C14) : AppColors.background;
  Color get cardBg => isDarkMode ? AppColors.primary800 : Colors.white;
  Color get cardBgElevated => isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get textPrimary => isDarkMode ? Colors.white : AppColors.stone900;
  Color get textSecondary => isDarkMode ? AppColors.primary200 : AppColors.stone600;
  Color get textMuted => isDarkMode ? AppColors.primary400 : AppColors.stone400;
  Color get iconPrimary => isDarkMode ? Colors.white : AppColors.primary900;
  Color get divider => isDarkMode ? Colors.white.withValues(alpha: 0.08) : AppColors.stone200;
  Color get inputBg => isDarkMode ? AppColors.primary800 : AppColors.stone50;
  Color get sheetBg => isDarkMode ? AppColors.primary800 : Colors.white;
  Color get shimmerBase => isDarkMode ? AppColors.primary700 : Colors.grey[300]!;
  Color get shimmerHighlight => isDarkMode ? AppColors.primary800 : Colors.grey[100]!;

  // Glassmorphism helpers
  Color get glassBg => isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.7);
  Color get glassBorder => isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.8);
}
