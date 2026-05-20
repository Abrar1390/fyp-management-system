import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

enum ThemeType { light, dark, black }

class ThemeProvider extends ChangeNotifier {
  ThemeType _currentTheme = ThemeType.light;

  ThemeType get currentTheme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeData getTheme() {
    switch (_currentTheme) {
      case ThemeType.light:
        return AppTheme.lightTheme();
      case ThemeType.dark:
        return AppTheme.darkTheme();
      case ThemeType.black:
        return AppTheme.blackTheme();
    }
  }

  void setTheme(ThemeType theme) {
    _currentTheme = theme;
    _saveTheme(theme);
    notifyListeners();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeType') ?? 0;
    _currentTheme = ThemeType.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveTheme(ThemeType theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeType', theme.index);
  }
}
