import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _themeKey = 'theme_mode';

  // Save theme selection (dark / light)
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  // Load theme selection, defaults to 'dark' as requested
  Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'dark';
  }
}
