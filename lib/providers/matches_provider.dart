import 'package:flutter/foundation.dart';
import '../models/match.dart'; import '../services/api_service.dart'; import '../services/storage_service.dart';
class MatchesProvider extends ChangeNotifier {
  final ApiService _api = ApiService(); final StorageService _storage = StorageService();
  List<MatchEvent> _matches = <MatchEvent>[]; Set<String> _favorites = <String>{}; bool _loading = false; String? _error;
  List<MatchEvent> get matches => _matches; Set<String> get favorites => _favorites; bool get loading => _loading; String? get error => _error;
  List<MatchEvent> get favoriteMatches => _matches.where(isFavorite).toList();
  Future<void> load() async { _favorites = await _storage.loadFavorites(); await refresh(); }
  Future<void> refresh() async {
    _loading = true; _error = null; notifyListeners();
    try { _api.setKey(await _storage.loadApiKey()); final list = await _api.fetchUpcoming(); if (list.isEmpty) { final sample = await _api.loadSample(); _matches = sample; _error = sample.isEmpty ? 'لا توجد مباريات متاحة حالياً' : null; } else { _matches = list; } } catch (_) { _error = 'تعذر جلب المباريات. تحقق من اتصالك.'; if (_matches.isEmpty) { _matches = await _api.loadSample(); } } finally { _loading = false; notifyListeners(); }
  }
  String _keyFor(MatchEvent match) => '${match.homeTeam}|${match.awayTeam}';
  bool isFavorite(MatchEvent match) => _favorites.contains(_keyFor(match));
  Future<void> toggleFavorite(MatchEvent match) async { final key = _keyFor(match); if (_favorites.contains(key)) { _favorites.remove(key); } else { _favorites.add(key); } await _storage.saveFavorites(_favorites); notifyListeners(); }
  Future<void> clearFavorites() async { _favorites.clear(); await _storage.saveFavorites(_favorites); notifyListeners(); }
}
