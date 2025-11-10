import 'package:flutter/material.dart';

class TasteGraphScreen extends StatelessWidget {
  static const route = '/taste_graph';

  const TasteGraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taste Graph (stub)')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Your flavor map will live here.\n\n'
            'Next steps:\n'
            '• Visualize cuisines and items you like.\n'
            '• Show clusters by spice/umami/sour/sweet.\n'
            '• Tap a node to see matching spots nearby.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
