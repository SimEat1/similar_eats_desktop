import 'package:flutter/material.dart';

class TasteQuizScreen extends StatelessWidget {
  const TasteQuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Taste Quiz')),
      body: const Center(
        child: Text('Onboarding / Taste Quiz goes here'),
      ),
    );
  }
}
