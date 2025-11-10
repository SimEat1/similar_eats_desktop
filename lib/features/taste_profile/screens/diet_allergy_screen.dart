import 'package:flutter/material.dart';
import 'package:similar_eats_desktop/features/taste_profile/taste_quiz_save.dart';

class DietAllergyScreen extends StatefulWidget {
  static const route = '/diet_allergies';
  const DietAllergyScreen({super.key});

  @override
  State<DietAllergyScreen> createState() => _DietAllergyScreenState();
}

class _DietAllergyScreenState extends State<DietAllergyScreen> {
  // simple tag sets; you can expand later
  final List<String> cuisines = [
    'Sushi',
    'BBQ',
    'Ethiopian',
    'Indian',
    'Thai',
    'Greek',
    'French',
    'Mexican',
    'Chinese',
    'Italian',
  ];
  final List<String> restrictions = [
    'Gluten-free',
    'Dairy-free',
    'Vegan',
    'Vegetarian',
    'Keto',
    'Halal',
    'Kosher',
    'Low-sodium',
  ];
  final List<String> hardNo = [
    'Cilantro',
    'Blue cheese',
    'Anchovies',
    'Raw onion',
    'Peanut',
    'Shellfish',
    'Pork',
    'Beef',
    'Chicken',
  ];

  final Set<String> avoidCuisines = {};
  final Set<String> dietRestrictions = {};
  final Set<String> hardNoItems = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet & allergies'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text('Cuisines to avoid', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _Chips(
            all: cuisines,
            selected: avoidCuisines,
            onChanged: (s) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Restrictions', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _Chips(
            all: restrictions,
            selected: dietRestrictions,
            onChanged: (s) => setState(() {}),
          ),
          const SizedBox(height: 20),
          Text('Hard no items', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _Chips(
            all: hardNo,
            selected: hardNoItems,
            onChanged: (s) => setState(() {}),
            allowCustom:
                true, // allow user to add their own (e.g., “German”, “Pizza”)
          ),
          const SizedBox(height: 12),
          Text(
            "Tip: These refine recommendations everywhere (dinner, map, group match). You can tweak them any time.",
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Save & close'),
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await TasteQuizSaver().savePrefs({
      'avoidCuisines': avoidCuisines.toList(),
      'restrictions': dietRestrictions.toList(),
      'hardNoItems': hardNoItems.toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
    if (mounted) Navigator.pop(context);
  }
}

class _Chips extends StatefulWidget {
  final List<String> all;
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  final bool allowCustom;
  const _Chips(
      {required this.all,
      required this.selected,
      required this.onChanged,
      this.allowCustom = false});

  @override
  State<_Chips> createState() => _ChipsState();
}

class _ChipsState extends State<_Chips> {
  late List<String> data = List.of(widget.all);

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final t in data)
        Padding(
          padding: const EdgeInsets.only(right: 8, bottom: 8),
          child: FilterChip(
            label: Text(t),
            selected: widget.selected.contains(t),
            onSelected: (v) {
              setState(() {
                if (v) {
                  widget.selected.add(t);
                } else {
                  widget.selected.remove(t);
                }
              });
              widget.onChanged(widget.selected);
            },
          ),
        ),
      if (widget.allowCustom)
        InputChip(
          label: const Text('Add custom'),
          avatar: const Icon(Icons.add),
          onPressed: () async {
            final txt = await showDialog<String>(
              context: context,
              builder: (ctx) {
                final c = TextEditingController();
                return AlertDialog(
                  title: const Text('Add custom item'),
                  content: TextField(controller: c, autofocus: true),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, c.text.trim()),
                        child: const Text('Add')),
                  ],
                );
              },
            );
            if (txt != null && txt.isNotEmpty) {
              setState(() {
                data.add(txt);
                widget.selected.add(txt);
              });
              widget.onChanged(widget.selected);
            }
          },
        ),
    ];

    return Wrap(children: chips);
  }
}
