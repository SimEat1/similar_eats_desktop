import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/features/try_list/screens/try_list_screen.dart'
    as legacy_try; // keep alias: matches your routes/main

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Similar Eats'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader('What\'s for dinner?'),
          _HomeTile(
            key: const Key('home-dinner'),
            icon: Icons.restaurant_menu_rounded,
            title: 'Find spots that match me',
            subtitle: 'Uses your taste profile (coming soon)',
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recommendations coming soon', key: Key('snack-recs')),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const _SectionHeader('Essentials'),
          _HomeTile(
            key: const Key('home-try-list'),
            icon: Icons.playlist_add_check_rounded,
            title: 'Try list',
            subtitle: 'Save places you want to try',
            onTap: () => Navigator.pushNamed(context, legacy_try.TryListScreen.route),
          ),
          _HomeTile(
            key: const Key('home-explore'),
            icon: Icons.map_rounded,
            title: 'Explore map',
            subtitle: 'Browse by map near you',
            onTap: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Explore map placeholder', key: Key('snack-explore')),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFEDE6),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 28),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
