import "package:flutter/material.dart";
import 'package:similar_eats_desktop/features/group_match/group_match_screen.dart';

class GroupMatchEntryScreen extends StatelessWidget {
  static const routeName = "/group-match";
  const GroupMatchEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the sample for now; later we’ll pass real group + center
    return GroupMatchScreen.sample();
  }
}
