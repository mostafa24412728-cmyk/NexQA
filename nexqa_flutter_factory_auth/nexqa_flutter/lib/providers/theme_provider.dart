import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

enum ThemePreference { dark, light, system }

class ThemeProvider extends ChangeNotifier {
  ThemePreference _preference = ThemePreference.dark;
  Brightness _systemBrightness = Brightness.dark;

  ThemePreference get preference => _preference;

  bool get isDark {
    if (_preference == ThemePreference.system) {
      return _systemBrightness == Brightness.dark;
    }
    return _preference == ThemePreference.dark;
  }

  AppColors get colors => isDark ? AppColors.dark : AppColors.light;

  ThemeMode get themeMode {
    switch (_preference) {
      case ThemePreference.dark:
        return ThemeMode.dark;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_preference') ?? 'dark';
    _preference = ThemePreference.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => ThemePreference.dark,
    );
    notifyListeners();
  }

  Future<void> setPreference(ThemePreference pref) async {
    _preference = pref;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_preference', pref.name);
    notifyListeners();
  }

  void updateSystemBrightness(Brightness brightness) {
    _systemBrightness = brightness;
    if (_preference == ThemePreference.system) {
      notifyListeners();
    }
  }
}
