import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'text_styles.dart';

/// Wavemart App Theme
/// Comprehensive theme configuration matching the web design system
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

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
        surface: Colors.white,
        onSurface: AppColors.stone900,
        onSurfaceVariant: AppColors.stone600,
        outline: AppColors.stone200,
      ),

      scaffoldBackgroundColor: AppColors.stone50,

      // Text Theme
      // NOTE: titleMedium MUST be a body font style — Flutter's DropdownButton
      // uses titleMedium for the selected-item label. Using Cinzel here was
      // causing all dropdowns to render in the decorative heading font.
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        displaySmall: AppTextStyles.headline3,
        headlineLarge: AppTextStyles.headline4,
        headlineMedium: AppTextStyles.headline5,
        headlineSmall: AppTextStyles.title,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.bodyMedium,
        titleSmall: AppTextStyles.eyebrow,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // AppBar Theme - Luxury Minimalist (Navy Authority)
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
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
          side: const BorderSide(color: AppColors.stone200, width: 1.0),
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
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary900,
          side: const BorderSide(color: AppColors.primary900),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary900,
          ),
        ),
      ),

      // Input Decoration Theme - Clean Slate
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stone100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.stone300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.stone300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accent500, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.stone700,
          fontWeight: FontWeight.w900,
        ),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary900,
          fontWeight: FontWeight.w900,
        ),
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

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        titleTextStyle: AppTextStyles.title.copyWith(
          color: AppColors.stone900,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.stone600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Checkbox Theme - compact spacing for custom font metrics
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        labelStyle: AppTextStyles.bodySmall,
      ),

      // ListTile Theme
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodySmall,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme - Dark Navy + Emerald Accent
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent400,
        onPrimary: Colors.black,
        primaryContainer: AppColors.accent900,
        onPrimaryContainer: AppColors.accent200,
        secondary: AppColors.primary300,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.primary800,
        onSecondaryContainer: AppColors.primary200,
        tertiary: AppColors.cta400,
        onTertiary: Colors.black,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.primary800,
        onSurface: Colors.white,
        onSurfaceVariant: AppColors.primary300,
        outline: AppColors.primary600,
      ),

      // Text Theme - Use AppTextStyles as the default for all text
      // NOTE: titleMedium stays as body font — same fix as light theme.
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1,
        displayMedium: AppTextStyles.headline2,
        displaySmall: AppTextStyles.headline3,
        headlineLarge: AppTextStyles.headline4,
        headlineMedium: AppTextStyles.headline5,
        headlineSmall: AppTextStyles.title,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.bodyMedium,
        titleSmall: AppTextStyles.eyebrow,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonLarge,
        labelMedium: AppTextStyles.buttonMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Scaffold
      scaffoldBackgroundColor: const Color(0xFF080C14),
      canvasColor: AppColors.primary800,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),

      // Card Theme - Dark Elevated Surface
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.primary800,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button Theme - Dark Emerald
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent500,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Outlined Button Theme - Dark
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent400,
          side: const BorderSide(color: AppColors.accent400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.accent400,
          ),
        ),
      ),

      // Filled Button Theme
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

      // Input Decoration Theme - Dark Mode
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.primary800,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.accent400, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary400,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary300,
          fontWeight: FontWeight.w900,
        ),
        floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.accent400,
          fontWeight: FontWeight.w900,
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.primary800,
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

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.primary800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.primary800,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: Colors.white,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary200,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
        ),
      ),

      // ListTile Theme
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppTextStyles.bodyLarge,
        subtitleTextStyle: AppTextStyles.bodySmall,
      ),
    );
  }
}
