import 'package:flutter/material.dart';

class TasteQuizScreen extends StatefulWidget {
  const TasteQuizScreen({super.key});
  @override
  State<TasteQuizScreen> createState() => _TasteQuizScreenState();
}

class _TasteQuizScreenState extends State<TasteQuizScreen> {
  final _answers = <String, bool>{'spicy': false, 'sweet': false, 'savory': true};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taste Quiz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pick what fits you (quick demo):'),
          const SizedBox(height: 12),
          ..._answers.keys.map((k) => SwitchListTile(
                title: Text(k[0].toUpperCase() + k.substring(1)),
                value: _answers[k] ?? false,
                onChanged: (v) => setState(() => _answers[k] = v),
              )),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              // TODO: save under users/{uid}/prefs
              Navigator.pop(context);
            },
            child: const Text('Save & Continue'),
          ),
        ],
      ),
    );
  }
}
