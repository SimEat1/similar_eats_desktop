import 'package:flutter/material.dart';

class QuickEatsMainScreen extends StatelessWidget {
  const QuickEatsMainScreen({super.key});
  static const routeName = '/quick-eats-main';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Eats (stub)')),
      body: const Center(child: Text('Coming soon: time-boxed meal ideas.')),
    );
  }
}
