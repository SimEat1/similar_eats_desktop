import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/core/app_state.dart';

class ChooseCategoriesScreen extends StatefulWidget {
  static const route = '/choose';
  const ChooseCategoriesScreen({super.key});

  @override
  State<ChooseCategoriesScreen> createState() => _ChooseCategoriesScreenState();
}

class _ChooseCategoriesScreenState extends State<ChooseCategoriesScreen> {
  // Base options (you can tweak anytime)
  static const _options = <String>[
    'Chicken',
    'Pizza',
    'Burgers',
    'Salad',
    'BBQ',
    'Tacos',
    'Wings',
    'Dessert',
    'Sushi',
    'Pasta',
    'Ramen',
    'Seafood',
  ];

  final Set<String> _temp = {...AppState.instance.selectedCategories.value};
  final TextEditingController _text = TextEditingController();

  void _toggle(String label) {
    setState(() {
      if (_temp.contains(label)) {
        _temp.remove(label);
      } else {
        _temp.add(label);
      }
    });
  }

  void _commitAndClose() {
    AppState.instance.selectedCategories.value = {..._temp};
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("What's for dinner?"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Pick one or more categories',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 12),

          // Grid of selectable chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final label in _options)
                FilterChip(
                  label: Text(label),
                  selected: _temp.contains(label),
                  onSelected: (_) => _toggle(label),
                ),
            ],
          ),

          const SizedBox(height: 20),
          TextField(
            controller: _text,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.edit_note_rounded),
              hintText: "Can't find it? Write it in (e.g., Pad See Ew)",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onSubmitted: (v) {
              final t = v.trim();
              if (t.isNotEmpty) {
                setState(() {
                  _temp.add(t);
                  _text.clear();
                });
              }
            },
          ),

          const SizedBox(height: 16),
          FilledButton(
            onPressed: _commitAndClose,
            child: const Text('Find options'),
          ),
        ],
      ),
    );
  }
}
