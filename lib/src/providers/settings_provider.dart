import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  SettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs?.getInt('theme_mode');
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }
    final localeCode = _prefs?.getString('locale');
    if (localeCode != null && localeCode.isNotEmpty) {
      _locale = Locale(localeCode);
    }
    notifyListeners();
  }

  Future<void> _ensurePrefs() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
  }

  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    // Ensure preferences are available; save when ready.
    _ensurePrefs().then((_) {
      _prefs?.setInt('theme_mode', mode.index);
    });
    notifyListeners();
  }

  void toggleDarkMode(bool enabled) {
    setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  void setLocale(Locale locale) {
    if (locale == _locale) return;
    _locale = locale;
    // Ensure preferences are available; save when ready.
    _ensurePrefs().then((_) {
      _prefs?.setString('locale', locale.languageCode);
    });
    notifyListeners();
  }
}
