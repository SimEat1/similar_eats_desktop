import 'package:flutter/material.dart';

/// Result returned to the caller (Taste Quiz) when user taps Continue.
class DietAllergyResult {
  final Set<String> allergies;
  final Set<String> diets;
  final bool hideMismatches; // if true, hide places that don't fit

  DietAllergyResult({
    required this.allergies,
    required this.diets,
    required this.hideMismatches,
  });
}

class DietAllergyStep extends StatefulWidget {
  static const routeName = '/diet_allergy';
  const DietAllergyStep({super.key});

  @override
  State<DietAllergyStep> createState() => _DietAllergyStepState();
}

class _DietAllergyStepState extends State<DietAllergyStep> {
  // Top 8 allergens (FAO/US common set)
  static const List<String> _allergens = <String>[
    'Gluten',
    'Dairy',
    'Eggs',
    'Soy',
    'Peanuts',
    'Tree Nuts',
    'Fish',
    'Shellfish',
  ];

  // Common dietary patterns/preferences
  static const List<String> _diets = <String>[
    'Vegan',
    'Vegetarian',
    'Pescatarian',
    'Keto',
    'Halal',
    'Kosher',
  ];

  final _selectedAllergens = <String>{};
  final _selectedDiets = <String>{};
  bool _hideMismatches = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Diet & Allergies')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              "Any diets or allergies we should know about?",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This helps us filter recommendations and avoid showing places that clash with your needs.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            _SectionLabel('Allergies (select any)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allergens.map((name) {
                final selected = _selectedAllergens.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v
                          ? _selectedAllergens.add(name)
                          : _selectedAllergens.remove(name);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            _SectionLabel('Dietary preferences'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _diets.map((name) {
                final selected = _selectedDiets.contains(name);
                return FilterChip(
                  label: Text(name),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      v
                          ? _selectedDiets.add(name)
                          : _selectedDiets.remove(name);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            SwitchListTile(
              value: _hideMismatches,
              title: const Text(
                'Hide places that don’t match my diet/allergies',
              ),
              subtitle: const Text(
                'If off, we’ll still show them but push them down.',
              ),
              onChanged: (v) => setState(() => _hideMismatches = v),
            ),

            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final result = DietAllergyResult(
                  allergies: Set<String>.from(_selectedAllergens),
                  diets: Set<String>.from(_selectedDiets),
                  hideMismatches: _hideMismatches,
                );
                Navigator.of(context).pop(result);
              },
              child: const Text('Continue'),
            ),

            TextButton(
              onPressed: () => Navigator.of(context).pop(
                DietAllergyResult(
                  allergies: {},
                  diets: {},
                  hideMismatches: _hideMismatches,
                ),
              ),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
