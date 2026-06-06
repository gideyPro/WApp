import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_theme.dart';

/// Hive box name shared by all non-draft app preferences (locale, theme, etc).
/// Opened centrally in `main.dart` to avoid scattered `Hive.openBox` calls.
const String kPrefsBox = 'app_preferences';

/// Keys inside the [kPrefsBox].
class PrefsKey {
  PrefsKey._();
  static const String locale = 'locale';
  static const String themeMode = 'theme_mode';
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadTheme();
  }

  Box get _box => Hive.box(kPrefsBox);

  Future<void> _loadTheme() async {
    try {
      final isDark = _box.get(PrefsKey.themeMode, defaultValue: false) as bool;
      state = isDark ? ThemeMode.dark : ThemeMode.light;
    } catch (_) {
      state = ThemeMode.light;
    }
  }

  Future<void> toggle() async {
    final newMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    try {
      await _box.put(PrefsKey.themeMode, newMode == ThemeMode.dark);
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      await _box.put(PrefsKey.themeMode, mode == ThemeMode.dark);
    } catch (_) {}
  }
}

ThemeData getThemeData(ThemeMode mode) {
  if (mode == ThemeMode.system) {
    final brightness = PlatformDispatcher.instance.platformBrightness;
    return brightness == Brightness.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
  }
  return mode == ThemeMode.dark ? AppTheme.darkTheme : AppTheme.lightTheme;
}
