// lib/features/taste_quiz/taste_quiz_screen.dart

import 'package:flutter/material.dart';

class TasteQuizScreen extends StatefulWidget {
  const TasteQuizScreen({super.key});

  @override
  State<TasteQuizScreen> createState() => _TasteQuizScreenState();
}

class _TasteQuizScreenState extends State<TasteQuizScreen> {
  int spiceTolerance = 50; // example slider value
  bool likesBbq = false;
  bool avoidsGreasy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Taste Quiz")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Set your taste profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 24),

            // Slider for spice tolerance
            Text("Spice tolerance: $spiceTolerance"),
            Slider(
              value: spiceTolerance.toDouble(),
              min: 0,
              max: 100,
              divisions: 10,
              label: "$spiceTolerance",
              onChanged: (val) {
                setState(() => spiceTolerance = val.toInt());
              },
            ),

            const SizedBox(height: 24),

            // BBQ preference
            CheckboxListTile(
              title: const Text("I like BBQ"),
              value: likesBbq,
              onChanged: (val) {
                setState(() => likesBbq = val ?? false);
              },
            ),

            // Greasy food avoidance
            CheckboxListTile(
              title: const Text("Avoid greasy foods"),
              value: avoidsGreasy,
              onChanged: (val) {
                setState(() => avoidsGreasy = val ?? false);
              },
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                // TODO: Save to Firebase or local taste profile repo
                Navigator.of(context).pop(); // go back after setup
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
