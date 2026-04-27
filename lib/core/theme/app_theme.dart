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
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.navy950,
        onPrimary: Colors.white,
        primaryContainer: AppColors.navy100,
        onPrimaryContainer: AppColors.navy900,
        secondary: AppColors.wave500,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.wave100,
        onSecondaryContainer: AppColors.wave900,
        tertiary: AppColors.emerald500,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.emerald100,
        onTertiaryContainer: AppColors.emerald900,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.zinc900,
        onSurfaceVariant: AppColors.zinc700,
        outline: AppColors.zinc300,
        shadow: AppColors.navy950,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.background,

      // AppBar Theme - Premium Floating Style
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.navy950,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: AppColors.navy950,
          size: 24,
        ),
        titleTextStyle: AppTextStyles.title.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
      ),

      // Card Theme - Smooth & Refined
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFFF1F5F9)), // Subtle slate border
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme - Modern Capsule
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.navy950,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      // Input Decoration Theme - Elegant Floating
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.zinc200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.zinc200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.navy950, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.zinc400),
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: AppColors.wave50,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navActive;
          }
          return AppTextStyles.navInactive;
        }),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFF1F5F9),
        thickness: 1,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme - Deep Night Premium
      colorScheme: const ColorScheme.dark(
        primary: AppColors.wave400,
        onPrimary: Colors.black,
        primaryContainer: AppColors.wave800,
        onPrimaryContainer: AppColors.wave100,
        secondary: AppColors.navy300,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.navy800,
        onSecondaryContainer: AppColors.navy100,
        tertiary: AppColors.emerald400,
        onTertiary: Colors.black,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.navy950,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.navy300,
        outline: AppColors.navy700,
        shadow: Colors.black,
      ),

      // Scaffold - Dark Luxury
      scaffoldBackgroundColor: AppColors.navy950,

      // AppBar Theme - Dark Transparent
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),

      // Card Theme - Elevate with subtle border
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.navy900,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),

      // Elevated Button Theme - Dark Emerald
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.wave500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      // Input Decoration Theme - Dark Floating
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navy900,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.wave400, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.navy400),
      ),

      // Navigation Bar - Dark Premium
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navy950,
        elevation: 0,
        indicatorColor: AppColors.wave800.withOpacity(0.5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navActive.copyWith(color: AppColors.wave400);
          }
          return AppTextStyles.navInactive.copyWith(color: AppColors.navy400);
        }),
      ),
      
      // Bottom Sheet Theme - Dark
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.navy900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }

}
