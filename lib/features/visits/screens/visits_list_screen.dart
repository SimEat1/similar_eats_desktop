import 'package:flutter/material.dart';

class VisitsListScreen extends StatelessWidget {
  const VisitsListScreen({super.key});
  static const routeName = '/visits';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visits (stub)')),
      body: const Center(child: Text('Visit history UI is being rebuilt.')),
    );
  }
}
