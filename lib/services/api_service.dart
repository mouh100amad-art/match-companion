import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../models/match.dart';

class ApiService {
  static const String _base = 'https://www.thesportsdb.com/api/v1/json';
  static const List<int> _leagueIds = [4328, 4335, 4332, 4331, 4334, 4480];
  String _key = '3';

  void setKey(String value) {
    final trimmed = value.trim();
    _key = trimmed.isEmpty ? '3' : trimmed;
  }

  Future<List<MatchEvent>> fetchUpcoming() async {
    final results = await Future.wait(_leagueIds.map(_fetchLeague));
    final all = results.expand((list) => list).toList();
    final seen = <String>{};
    final unique = all.where((m) => seen.add(m.id)).toList();
    unique.sort((a, b) => a.utcTime.compareTo(b.utcTime));
    final cutoff = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    return unique.where((m) => m.utcTime.isAfter(cutoff)).toList();
  }

  Future<List<MatchEvent>> _fetchLeague(int id) async {
    try {
      final uri = Uri.parse('$_base/$_key/eventsnextleague.php?id=$id');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return <MatchEvent>[];
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) return <MatchEvent>[];
      final events = data['events'];
      if (events is! List) return <MatchEvent>[];
      return events.whereType<Map<String, dynamic>>().map(MatchEvent.fromSportsDb).toList();
    } catch (_) {
      return <MatchEvent>[];
    }
  }

  Future<List<MatchEvent>> loadSample() async {
    try {
      final raw = await rootBundle.loadString('assets/sample_matches.json');
      final list = jsonDecode(raw);
      if (list is! List) return <MatchEvent>[];
      return list.whereType<Map<String, dynamic>>().map(MatchEvent.fromSportsDb).toList();
    } catch (_) {
      return <MatchEvent>[];
    }
  }
}
