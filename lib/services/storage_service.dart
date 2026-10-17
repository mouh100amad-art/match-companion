import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _favKey = 'favorites_v1';
  static const _remindersKey = 'reminders_v1';
  static const _apiKeyKey = 'api_key_v1';
  static const _themeKey = 'theme_mode_v1';

  Future<Set
