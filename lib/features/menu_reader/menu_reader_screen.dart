import 'package:flutter/material.dart';

class MenuReaderScreen extends StatelessWidget {
  static const route = '/menu_reader';
  const MenuReaderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visual Menu Reader')),
      body: const Center(
        child: Text(
          'Snap/Upload menu → OCR → highlight items you’d love.\nStub UI for now.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


