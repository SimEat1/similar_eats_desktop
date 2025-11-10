import 'package:flutter/material.dart';

class GroupMatchLiveScreen extends StatelessWidget {
  const GroupMatchLiveScreen({super.key});
  static const routeName = '/group-match-live';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Match (coming soon)')),
      body: const Center(
        child: Text('Live group matching is under construction.'),
      ),
    );
  }
}
