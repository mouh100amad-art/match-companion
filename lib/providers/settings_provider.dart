import 'package:flutter/material.dart';
import '../services/storage_service.dart';
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  ThemeMode _themeMode = ThemeMode.system; String _apiKey = '3'; int _defaultReminder = 15;
  ThemeMode get themeMode => _themeMode; String get apiKey => _apiKey; int get defaultReminder => _defaultReminder;
  Future<void> load() async { _apiKey = await _storage.loadApiKey(); final mode = await _storage.loadThemeMode(); _themeMode = _parseThemeMode(mode); notifyListeners(); }
  Future<void> setThemeMode(ThemeMode mode) async { _themeMode = mode; await _storage.saveThemeMode(_themeMode.name); notifyListeners(); }
  Future<void> setApiKey(String value) async { _apiKey = value.trim().isEmpty ? '3' : value.trim(); await _storage.saveApiKey(_apiKey); notifyListeners(); }
  Future<void> setDefaultReminder(int minutes) async { _defaultReminder = minutes; notifyListeners(); }
  ThemeMode _parseThemeMode(String? value) { switch (value) { case 'light': return ThemeMode.light; case 'dark': return ThemeMode.dark; default: return ThemeMode.system; } }
}
