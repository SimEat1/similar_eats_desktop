import 'package:flutter/material.dart';

class TryListButton extends StatelessWidget {
  const TryListButton({super.key, required this.inList, required this.onToggle});
  final bool inList;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: inList ? 'Remove from Try List' : 'Add to Try List',
      icon: Icon(inList ? Icons.bookmark : Icons.bookmark_outline),
      onPressed: onToggle,
    );
  }
}
