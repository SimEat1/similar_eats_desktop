import 'package:flutter/material.dart';

class TryListScreen extends StatelessWidget {
  const TryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Load actual try list; placeholder UI for now
    return Scaffold(
      appBar: AppBar(title: const Text('My Try List')),
      body: const Center(child: Text('Your saved places will appear here.')),
    );
  }
}
