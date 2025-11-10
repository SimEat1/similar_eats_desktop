import 'package:flutter/material.dart';

class QuickEatsScreen extends StatelessWidget {
  const QuickEatsScreen({super.key});
  static const routeName = '/quick-eats';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Eats (stub)')),
      body: const Center(child: Text('Quick Eats prototype temporarily stubbed.')),
    );
  }
}
