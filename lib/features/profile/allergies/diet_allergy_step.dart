import "package:flutter/material.dart";

/// Enums used across the app (persisted by .name)
enum DietType {
  none,
  vegetarian,
  vegan,
  pescatarian,
  halal,
  kosher,
  keto,
  paleo
}

enum Allergy { none, peanuts, treeNuts, shellfish, dairy, gluten, eggs, soy }

enum AvoidFood { none, spicy, pork, chicken, beef, fish, alcohol }

typedef DietAllergyChanged = void Function(
  Set<DietType> diets,
  Set<Allergy> allergies,
  Set<AvoidFood> avoids,
  Set<String> friesLikes,
  Set<String> friesDislikes,
);

class DietAllergyStep extends StatefulWidget {
  final Set<DietType> initialDiets;
  final Set<Allergy> initialAllergies;
  final Set<AvoidFood> initialAvoids;

  /// Micro-preferences for fries
  final Set<String> friesLikes;
  final Set<String> friesDislikes;

  final DietAllergyChanged onChanged;

  const DietAllergyStep({
    super.key,
    required this.initialDiets,
    required this.initialAllergies,
    required this.initialAvoids,
    this.friesLikes = const <String>{},
    this.friesDislikes = const <String>{},
    required this.onChanged,
  });

  @override
  State<DietAllergyStep> createState() => _DietAllergyStepState();
}

class _DietAllergyStepState extends State<DietAllergyStep> {
  late final Set<DietType> _diets = {...widget.initialDiets};
  late final Set<Allergy> _allergies = {...widget.initialAllergies};
  late final Set<AvoidFood> _avoids = {...widget.initialAvoids};

  late final Set<String> _friesLikes = {...widget.friesLikes};
  late final Set<String> _friesDislikes = {...widget.friesDislikes};

  // Options
  final _dietOpts = DietType.values;
  final _allergyOpts = Allergy.values;
  final _avoidOpts = AvoidFood.values;

  static const _friesOptions = <String>[
    "crinkle",
    "shoestring",
    "skin-on",
    "waffle",
    "curly",
    "steak",
    "crispy",
    "soft",
  ];

  void _emit() {
    widget.onChanged(_diets, _allergies, _avoids, _friesLikes, _friesDislikes);
  }

  Widget _chipRow<T>({
    required Iterable<T> options,
    required bool Function(T) isSelected,
    required void Function(T, bool) onToggle,
    String Function(T)? labelOf,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final sel = isSelected(opt);
        final label = labelOf != null ? labelOf(opt) : opt.toString();
        return FilterChip(
          label: Text(label),
          selected: sel,
          onSelected: (v) => setState(() {
            onToggle(opt, v);
            _emit();
          }),
        );
      }).toList(),
    );
  }

  String _enumLabel(Object e) {
    // Works on all Dart versions: "DietType.vegetarian" -> "Vegetarian"
    final s = e.toString();
    final i = s.indexOf(".");
    final raw = i >= 0 ? s.substring(i + 1) : s;
    return raw.isEmpty ? raw : (raw[0].toUpperCase() + raw.substring(1));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Diet", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _chipRow<DietType>(
            options: _dietOpts,
            isSelected: (e) => _diets.contains(e),
            onToggle: (e, v) => v ? _diets.add(e) : _diets.remove(e),
            labelOf: _enumLabel,
          ),
          const SizedBox(height: 16),

          Text("Allergies", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _chipRow<Allergy>(
            options: _allergyOpts,
            isSelected: (e) => _allergies.contains(e),
            onToggle: (e, v) => v ? _allergies.add(e) : _allergies.remove(e),
            labelOf: _enumLabel,
          ),
          const SizedBox(height: 16),

          Text("Avoid", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _chipRow<AvoidFood>(
            options: _avoidOpts,
            isSelected: (e) => _avoids.contains(e),
            onToggle: (e, v) => v ? _avoids.add(e) : _avoids.remove(e),
            labelOf: _enumLabel,
          ),
          const SizedBox(height: 16),
// Fries Likes hidden
          const SizedBox.shrink(),
// Fries Dislikes hidden
          const SizedBox.shrink(),
        ],
      ),
    );
  }
}
