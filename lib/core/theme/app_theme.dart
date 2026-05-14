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

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary600,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primary100,
        onPrimaryContainer: AppColors.primary900,
        secondary: AppColors.accent600,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accent100,
        onSecondaryContainer: AppColors.accent900,
        tertiary: AppColors.cta700,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.cta100,
        onTertiaryContainer: AppColors.cta900,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.primary50,
        onSurface: AppColors.primary800,
        onSurfaceVariant: AppColors.primary600,
        outline: AppColors.primary200,
        shadow: AppColors.primary700,
      ),

      // Legacy support for older SDKs
      primaryColor: AppColors.primary600,
      canvasColor: Colors.white,
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.accent600,
        textTheme: ButtonTextTheme.primary,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.primary50,

      // AppBar Theme - Premium Floating Style
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primary800,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(
          color: AppColors.primary700,
          size: 24,
        ),
        titleTextStyle: AppTextStyles.title.copyWith(
          fontFamily: 'Cinzel',
          color: AppColors.primary900,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Card Theme - Glassmorphism
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.7),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.white.withOpacity(0.8)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme - Accent Gradient
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.accent600,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Filled Button Theme - M3
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent600,
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
          foregroundColor: AppColors.primary600,
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration Theme - Elegant Floating
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: AppColors.primary200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: AppColors.primary200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accent500, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary300),
      ),

      // Navigation Bar Theme (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.7),
        elevation: 0,
        indicatorColor: AppColors.accent50,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navActive;
          }
          return AppTextStyles.navInactive;
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

      // Color Scheme - Deep Night Premium
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent400,
        onPrimary: Colors.black,
        primaryContainer: AppColors.accent800,
        onPrimaryContainer: AppColors.accent100,
        secondary: AppColors.primary300,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.primary800,
        onSecondaryContainer: AppColors.primary100,
        tertiary: AppColors.cta400,
        onTertiary: Colors.black,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.primary900,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.primary300,
        outline: AppColors.primary700,
        shadow: Colors.black,
      ),

      // Legacy support for older SDKs
      primaryColor: AppColors.accent500,
      canvasColor: AppColors.primary900,
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.accent500,
        textTheme: ButtonTextTheme.primary,
      ),

      // Scaffold - Dark Luxury
      scaffoldBackgroundColor: AppColors.primary900,

      // AppBar Theme - Dark Transparent
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          fontFamily: 'Cinzel',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Card Theme - Dark Glass
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.primary800,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),

      // Elevated Button Theme - Dark Emerald
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(fontWeight: FontWeight.w600),
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
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
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
        indicatorColor: AppColors.accent800.withOpacity(0.5),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.navActive.copyWith(color: AppColors.accent400);
          }
          return AppTextStyles.navInactive.copyWith(color: AppColors.primary400);
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
