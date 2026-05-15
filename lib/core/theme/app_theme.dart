import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// WaveMart App Theme
/// Comprehensive theme configuration matching the web design system
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Montserrat',

      // Color Scheme - Logo Navy & Emerald
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary900,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary100,
        onPrimaryContainer: AppColors.primary900,
        secondary: AppColors.accent500,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accent50,
        onSecondaryContainer: AppColors.accent900,
        tertiary: AppColors.cta700,
        onTertiary: Colors.white,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.background,
        onSurface: AppColors.stone900,
        onSurfaceVariant: AppColors.stone600,
        outline: AppColors.stone200,
      ),

      // AppBar Theme - Luxury Minimalist (Navy Authority)
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.stone900,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: AppColors.primary900,
          fontWeight: FontWeight.w800,
        ),
      ),

      // Card Theme - Quiet Luxury
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.stone100, width: 1.0),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme - Authoritative Navy
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary900,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Input Decoration Theme - Clean Slate
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stone50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.stone200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.stone200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.accent500, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone500),
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.7),
        elevation: 0,
        indicatorColor: AppColors.accent50,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navActive.copyWith(fontWeight: FontWeight.w900);
          }
          return AppTextStyles.navInactive.copyWith(fontWeight: FontWeight.w700);
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.primary200,
        thickness: 1,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Montserrat',

      // Color Scheme - Deep Night Logo Navy
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent400,
        onPrimary: Colors.black,
        primaryContainer: AppColors.primary800,
        onPrimaryContainer: AppColors.primary100,
        secondary: AppColors.primary300,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.primary900,
        onSecondaryContainer: AppColors.primary200,
        tertiary: AppColors.cta400,
        onTertiary: Colors.black,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.primary900,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.primary200,
        outline: AppColors.primary700,
      ),

      // Scaffold - Deep Midnight Authority
      scaffoldBackgroundColor: const Color(0xFF0B0F10),

      // AppBar Theme - Dark Transparent
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),

      // Card Theme - Dark Quiet Luxury
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.primary900,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),

      // Elevated Button Theme - Dark Emerald
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent500,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Filled Button Theme - M3
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent400,
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme - Dark Floating
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primary800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accent400, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary400),
      ),

      // Navigation Bar - Dark Premium
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.primary900,
        elevation: 0,
        indicatorColor: AppColors.accent800.withValues(alpha: 0.5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navActive.copyWith(
              color: AppColors.accent400,
              fontWeight: FontWeight.w900,
            );
          }
          return AppTextStyles.navInactive.copyWith(
            color: AppColors.primary300,
            fontWeight: FontWeight.w700,
          );
        }),
      ),

      // Bottom Sheet Theme - Dark
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.primary800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}
