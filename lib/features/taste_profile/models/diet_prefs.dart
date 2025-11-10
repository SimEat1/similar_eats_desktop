import "package:cloud_firestore/cloud_firestore.dart";

/// Dietary preferences captured separately from the numeric taste vector.
/// Keep choices human-readable lists so the UI is simple and Firestore is queryable.
class DietPrefs {
  /// e.g., ["vegan"], or multiple like ["vegetarian","pescatarian"].
  final List<String> dietStyles;

  /// e.g., ["gluten","peanut","dairy"].
  final List<String> allergens;

  /// e.g., ["pork","shellfish","cilantro","mayo"].
  final List<String> avoidItems;

  /// Freeform notes user might add later (optional).
  final String? notes;

  const DietPrefs({
    this.dietStyles = const [],
    this.allergens = const [],
    this.avoidItems = const [],
    this.notes,
  });

  Map<String, dynamic> toMap() => {
        "dietStyles": dietStyles,
        "allergens": allergens,
        "avoidItems": avoidItems,
        if (notes != null && notes!.trim().isNotEmpty) "notes": notes!.trim(),
        "updatedAt": FieldValue.serverTimestamp(),
        "schema": "v1",
      };

  factory DietPrefs.fromMap(Map<String, dynamic> m) {
    List<String> strList(dynamic v) =>
        (v is List) ? v.whereType<String>().toList() : const <String>[];
    return DietPrefs(
      dietStyles: strList(m["dietStyles"]),
      allergens: strList(m["allergens"]),
      avoidItems: strList(m["avoidItems"]),
      notes: (m["notes"] as String?)?.trim(),
    );
  }
}
