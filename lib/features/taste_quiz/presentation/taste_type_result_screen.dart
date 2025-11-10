import 'package:flutter/material.dart';

class TasteTypeResultScreen extends StatelessWidget {
  const TasteTypeResultScreen({super.key});
  static const routeName = '/taste-result';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your taste type')),
      body: const Center(
        child: Text('Your result will appear here (stub).'),
      ),
    );
  }
}
