import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/matches_provider.dart';
import '../widgets/match_card.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    final favorites = provider.favoriteMatches;
    if (favorites.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'لا توجد مباريات في المفضلة بعد.\nاضغط على النجمة في أي بطاقة مباراة.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView(children: favorites.map((m) => MatchCard(match: m)).toList());
  }
}
