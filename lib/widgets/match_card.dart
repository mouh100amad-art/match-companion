import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/match.dart';
import '../providers/matches_provider.dart';
import '../screens/match_details_screen.dart';

class MatchCard extends StatelessWidget {
  final MatchEvent match;
  const MatchCard({super.key, required this.match});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    final favorite = provider.isFavorite(match);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(match.league, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                  if (match.isLive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                      child: const Text('مباشر', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  IconButton(
                    tooltip: 'المفضلة',
                    icon: Icon(favorite ? Icons.star : Icons.star_border, color: favorite ? Colors.amber : null),
                    onPressed: () => provider.toggleFavorite(match),
                  )
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(child: Text(match.homeTeam, textAlign: TextAlign.right, style: theme.textTheme.titleMedium)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(DateFormat('HH:mm', 'ar').format(match.localTime), style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Text(match.awayTeam, textAlign: TextAlign.left, style: theme.textTheme.titleMedium))
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openDetails(context),
                      icon: const Icon(Icons.alarm, size: 18),
                      label: const Text('تذكير'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openDetails(context),
                      icon: const Icon(Icons.play_circle_outline, size: 18),
                      label: const Text('مشاهدة'),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _openDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MatchDetailsScreen(match: match)));
  }
}
