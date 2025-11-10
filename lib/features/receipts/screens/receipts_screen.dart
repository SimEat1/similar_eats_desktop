import 'package:flutter/material.dart';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});
  static const routeName = '/receipts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipts (stub)')),
      body: const Center(
        child: Text('Receipts viewer coming soon.'),
      ),
    );
  }
}
