import 'package:flutter/material.dart';
import 'favorites_tab.dart';
import 'matches_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رفيق المباريات')),
      body: IndexedStack(
        index: _index,
        children: const [MatchesTab(), FavoritesTab(), SettingsTab()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.sports_soccer), label: 'المباريات'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'الإعدادات')
        ],
      ),
    );
  }
}
