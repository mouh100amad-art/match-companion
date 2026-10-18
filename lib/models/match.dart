class MatchEvent {
  final String id; final String league; final String homeTeam; final String awayTeam;
  final String? homeBadge; final String? awayBadge; final DateTime utcTime;
  final String? venue; final String? status; final int? homeScore; final int? awayScore;
  const MatchEvent({required this.id, required this.league, required this.homeTeam, required this.awayTeam, this.homeBadge, this.awayBadge, required this.utcTime, this.venue, this.status, this.homeScore, this.awayScore});
  DateTime get localTime => utcTime.toLocal();
  bool get isLive { final s = (status ?? '').toLowerCase(); return s == 'live' || s == '1h' || s == '2h' || s == 'ht'; }
  factory MatchEvent.fromSportsDb(Map<String, dynamic> json) {
    final raw = json['strTimestamp']?.toString() ?? '${json['dateEvent'] ?? ''}T${json['strTime'] ?? '00:00:00'}';
    DateTime utc; try { utc = DateTime.parse(raw).toUtc(); } catch (_) { utc = DateTime.now().toUtc(); }
    return MatchEvent(id: json['idEvent']?.toString() ?? raw, league: json['strLeague']?.toString() ?? 'غير معروف', homeTeam: json['strHomeTeam']?.toString() ?? '', awayTeam: json['strAwayTeam']?.toString() ?? '', homeBadge: json['strHomeTeamBadge']?.toString(), awayBadge: json['strAwayTeamBadge']?.toString(), utcTime: utc, venue: json['strVenue']?.toString(), status: json['strStatus']?.toString(), homeScore: int.tryParse(json['intHomeScore']?.toString() ?? ''), awayScore: int.tryParse(json['intAwayScore']?.toString() ?? ''));
  }
}
