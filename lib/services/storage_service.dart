import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _favKey = 'favorites_v1';
  static const _remindersKey = 'reminders_v1';
  static const _apiKeyKey = 'api_key_v1';
  static const _themeKey = 'theme_mode_v1';

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favKey) ?? <String>[]).toSet();
  }
  Future<void> saveFavorites(Set<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favKey, value.toList());
  }
  Future<String> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey) ?? '3';
  }
  Future<void> saveApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, value);
  }
  Future<Map<String, int>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_remindersKey);
    if (raw == null) return <String, int>{};
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as int));
    } catch (_) {
      return <String, int>{};
    }
  }
  Future<void> saveReminders(Map<String, int> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_remindersKey, jsonEncode(value));
  }
  Future<String?> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
  Future<void> saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }
}
