import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/matches_provider.dart';
import '../widgets/match_card.dart';

class MatchesTab extends StatelessWidget {
  const MatchesTab({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    if (provider.loading && provider.matches.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.matches.isEmpty) {
      return RefreshIndicator(
        onRefresh: provider.refresh,
        child: ListView(children: [
          const SizedBox(height: 120),
          Icon(Icons.sports_soccer, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Center(child: Text(provider.error ?? 'لا توجد مباريات قادمة حالياً')),
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          )
        ]),
      );
    }
    final grouped = _group(provider.matches);
    final children = <Widget>[];
    grouped.forEach((date, list) {
      final parsed = DateTime.parse(date);
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(
          DateFormat('EEEE، d MMMM yyyy', 'ar').format(parsed),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ));
      children.addAll(list.map((m) => MatchCard(match: m)));
    });
    return RefreshIndicator(onRefresh: provider.refresh, child: ListView(children: children));
  }

  Map<String, List<MatchEvent>> _group(List<MatchEvent> list) {
    final map = <String, List<MatchEvent>>{};
    for (final match in list) {
      final key = DateFormat('yyyy-MM-dd').format(match.localTime);
      map.putIfAbsent(key, () => <MatchEvent>[]).add(match);
    }
    return map;
  }
}
