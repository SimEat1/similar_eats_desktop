import "package:flutter/material.dart";
import 'package:similar_eats_desktop/shared/portion.dart';
import 'package:similar_eats_desktop/shared/portion_size.dart';

class RecentVisitsScreen extends StatelessWidget {
  final Portion portion;
  const RecentVisitsScreen(
      {this.portion = const Portion(size: PortionSize.m), super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Recent visits")),
      body: const Center(child: Text("No recent visits yet")),
    );
  }
}
