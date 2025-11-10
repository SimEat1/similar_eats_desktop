import 'package:flutter/material.dart';

void main() => runApp(const _BackupApp());

class _BackupApp extends StatelessWidget {
  const _BackupApp();
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('backup main (stub)')),
      ),
    );
  }
}
