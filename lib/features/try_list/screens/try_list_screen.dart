import 'package:flutter/material.dart';

class TryListScreen extends StatelessWidget {
  const TryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Try List')),
      body: const Center(child: Text('Places I want to try')),
    );
  }
}
