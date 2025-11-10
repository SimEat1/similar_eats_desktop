import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Similar Eats')),
      body: const Center(
        child:
            Text('Home (stub) — header simplified to avoid analyzer errors.'),
      ),
    );
  }
}
