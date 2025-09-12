import 'package:flutter/material.dart';

typedef OnAdd = Future<void> Function(String name);

class TryListButton extends StatelessWidget {
  const TryListButton({super.key, required this.onAdd});
  final OnAdd onAdd;

  Future<void> _showAddDialog(BuildContext context) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add to Try List'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Restaurant name',
          ),
          onSubmitted: (_) => Navigator.of(context).pop(true),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
        ],
      ),
    );

    if (ok == true) {
      final name = controller.text.trim();
      if (name.isNotEmpty) {
        await onAdd(name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('Add'),
    );
  }
}





