import 'package:flutter/material.dart';

class ChallengesScreen extends StatelessWidget {
  static const route = '/challenges';
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = const [
      ('Spice Sprint', 'Try 3 spicy dishes this week'),
      ('Noodle Quest', 'Eat 2 new noodle styles'),
      ('Veg Victory', 'One plant-based lunch'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final (title, subtitle) = challenges[i];
          return Card(
            child: ListTile(
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: FilledButton(
                onPressed: () {},
                child: const Text('Join'),
              ),
            ),
          );
        },
      ),
    );
  }
}
