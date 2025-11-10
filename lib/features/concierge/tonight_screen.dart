import 'package:flutter/material.dart';

class TonightConciergeScreen extends StatelessWidget {
  static const route = '/tonight';

  const TonightConciergeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tonight's Concierge (stub)")),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Tell me your vibe and time window,\n'
            'I’ll suggest 3 perfect places tonight.\n\n'
            'Coming soon:\n'
            '• Uses your Taste Profile + recency\n'
            '• Filters by distance, open hours\n'
            '• One-tap directions & table link',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
