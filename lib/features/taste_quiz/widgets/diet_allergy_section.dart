import 'package:flutter/material.dart';

class DietAllergySection extends StatelessWidget {
  final Set<String> selectedDiets;
  final Set<String> selectedAllergies;

  const DietAllergySection({
    super.key,
    required this.selectedDiets,
    required this.selectedAllergies,
  });

  @override
  Widget build(BuildContext context) {
    String line(String label, Set<String> values) =>
        values.isEmpty ? '$label: None' : '$label: ${values.join(", ")}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(line('Diets', selectedDiets)),
        Text(line('Allergies', selectedAllergies)),
      ],
    );
  }
}
