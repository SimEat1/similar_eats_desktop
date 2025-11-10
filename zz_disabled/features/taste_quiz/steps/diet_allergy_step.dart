import 'package:flutter/material.dart';

class DietAllergyStep extends StatelessWidget {
  final Set<String> selectedDiets;
  final Set<String> selectedAllergies;
  final ValueChanged<Set<String>> onDietsChanged;
  final ValueChanged<Set<String>> onAllergiesChanged;

  const DietAllergyStep({
    super.key,
    required this.selectedDiets,
    required this.selectedAllergies,
    required this.onDietsChanged,
    required this.onAllergiesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final diets = <String>[
      'Vegetarian',
      'Vegan',
      'Pescatarian',
      'Halal',
      'Kosher',
      'Gluten-free',
      'Dairy-free',
      'Keto',
    ];
    final allergens = <String>[
      'Peanuts',
      'Tree nuts',
      'Shellfish',
      'Fish',
      'Milk',
      'Eggs',
      'Wheat',
      'Soy',
      'Sesame',
      'Gluten',
    ];

    Widget chips(List<String> items, Set<String> selected,
        ValueChanged<Set<String>> onChanged) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((item) {
          final isOn = selected.contains(item);
          return FilterChip(
            label: Text(item),
            selected: isOn,
            onSelected: (v) {
              final next = {...selected};
              v ? next.add(item) : next.remove(item);
              onChanged(next);
            },
          );
        }).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dietary preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        chips(diets, selectedDiets, onDietsChanged),
        const SizedBox(height: 24),
        const Text('Allergies',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        chips(allergens, selectedAllergies, onAllergiesChanged),
      ],
    );
  }
}
