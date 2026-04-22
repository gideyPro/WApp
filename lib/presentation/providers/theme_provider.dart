import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_theme.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String _boxKey = 'settings';
  static const String _themeKey = 'theme_mode';

  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final box = await Hive.openBox(_boxKey);
      final isDark = box.get(_themeKey, defaultValue: false) as bool;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      state = ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    try {
      final box = await Hive.openBox(_boxKey);
      await box.put(_themeKey, newMode == ThemeMode.dark);
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      final box = await Hive.openBox(_boxKey);
      await box.put(_themeKey, mode == ThemeMode.dark);
    } catch (_) {}
  }
}

ThemeData getThemeData(ThemeMode mode) {
  return mode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
}