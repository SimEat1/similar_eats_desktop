import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/features/solo_map/solo_map_screen.dart';
import 'package:similar_eats_desktop/features/taste_quiz/screens/taste_quiz_screen.dart';

class TonightScreen extends StatelessWidget {
  static const routeName = '/tonight';
  const TonightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text("What do you want to eat tonight?", style: h.headlineSmall),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_pin_circle_outlined),
              title: const Text("I'm eating solo"),
              subtitle: const Text('Use my taste profile with a map'),
              onTap: () =>
                  Navigator.pushNamed(context, SoloMapScreen.routeName),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.groups_2_outlined),
              title: const Text("I'm with my Tastebuds"),
              subtitle: const Text('Find places everyone can eat'),
              onTap: () => Navigator.pushNamed(context, '/tastebuds'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, TasteQuizScreen.routeName),
              child: const Text('Update my Taste Quiz'),
            ),
          ),
        ],
      ),
    );
  }
}
