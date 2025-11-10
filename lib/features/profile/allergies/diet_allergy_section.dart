import "package:flutter/material.dart";
import 'package:similar_eats_desktop/features/profile/allergies/diet_allergy_step.dart';

class DietAllergySection extends StatelessWidget {
  final Set<DietType> diets;
  final Set<Allergy> allergies;
  final Set<AvoidFood> avoids;

  const DietAllergySection({
    super.key,
    required this.diets,
    required this.allergies,
    required this.avoids,
  });

  String _enumLabel(Object e) {
    final s = e.toString();
    final i = s.indexOf(".");
    final raw = i >= 0 ? s.substring(i + 1) : s;
    return raw.isEmpty ? raw : (raw[0].toUpperCase() + raw.substring(1));
  }

  Widget _chipWrap(Iterable<String> items, TextStyle? style) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.isEmpty
          ? [Chip(label: Text("None", style: style))]
          : items.map((t) => Chip(label: Text(t, style: style))).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipStyle = theme.textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Diet", style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        _chipWrap(diets.map(_enumLabel), chipStyle),
        const SizedBox(height: 16),
        Text("Allergies", style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        _chipWrap(allergies.map(_enumLabel), chipStyle),
        const SizedBox(height: 16),
        Text("Avoid", style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        _chipWrap(avoids.map(_enumLabel), chipStyle),
      ],
    );
  }
}
