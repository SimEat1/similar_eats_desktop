import 'package:flutter/material.dart';

class SmartTagDemoScreen extends StatelessWidget {
  static const route = '/smart_tags';
  const SmartTagDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demoTags = ['crispy', 'spicy', 'tangy', 'umami', 'saucy'];
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Tags (Demo)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Upload a photo → auto-tags appear here (stub).'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: demoTags.map((t) => Chip(label: Text(t))).toList(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {},
              child: const Text('Try with a photo (coming soon)'),
            ),
          ],
        ),
      ),
    );
  }
}

