import 'package:flutter/material.dart';
import '../repositories/theme_repository.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeRepository _repository;
  ThemeMode _themeMode;

  ThemeProvider(this._repository, {String initialMode = 'dark'})
      : _themeMode = initialMode == 'light' ? ThemeMode.light : ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      await _repository.saveThemeMode('light');
    } else {
      _themeMode = ThemeMode.dark;
      await _repository.saveThemeMode('dark');
    }
    notifyListeners();
  }
}
