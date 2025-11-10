import 'package:flutter/material.dart';

class VoiceSearchScreen extends StatelessWidget {
  static const route = '/voice';
  const VoiceSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl =
        TextEditingController(text: 'Show me ramen under \$20 within 5 miles');
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Search')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
                'Microphone UI & speech-to-text coming later.\nType your query to simulate.'),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'Query',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'We will parse this into filters & run search.')),
                );
              },
              child: const Text('Run'),
            ),
            const Expanded(child: Center(child: Text('Results (stub)'))),
          ],
        ),
      ),
    );
  }
}
