import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:similar_eats_desktop/features/taste_profiles/taste_prompt.dart';
import 'package:similar_eats_desktop/features/taste_profiles/taste_events.dart';

import 'package:similar_eats_desktop/core/platform/platform_helper.dart';

/// Place this at the top of your Home screen.
class HomeHeaderPrompt extends StatelessWidget {
  const HomeHeaderPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = PlatformHelper.getCurrentUid(
        firebaseUid: FirebaseAuth.instance.currentUser?.uid);
    final prompt = randomPrompt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        if (uid != null)
          FutureBuilder<List<String>>(
            future: topChipsForUser(uid),
            builder: (ctx, snap) {
              final chips = snap.data ?? const <String>[];
              if (chips.isEmpty) {
                return const SizedBox.shrink();
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips.map((c) {
                  final raw = c.toLowerCase();
                  return ActionChip(
                    label: Text(c),
                    onPressed: () async {
                      // Treat tap as “I want this” -> like_tag + adapt
                      await TasteEvents.log(
                        uid: uid,
                        type: 'like_tag',
                        value: raw,
                        context: {'source': 'header_chip'},
                      );
                      await TasteAdaptiveUpdater().apply(
                        uid: uid,
                        type: 'like_tag',
                        value: raw,
                      );

                      // Optional: you can trigger a filtered reload of your feed here.
                      // e.g., navigate to QuickEats with a pre-filter, or call setState from parent.
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Noted: $c'),
                          duration: const Duration(milliseconds: 900),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}
