import 'package:similar_eats_desktop/features/profile/allergies/diet_allergy_step.dart';

/// Canonical taste profile persisted for a user.
class TasteProfile {
  final Set<String> flavors;
  final Set<String> cuisines;
  final String? budget; // "cheap" | "moderate" | "pricey"
  final Set<DietType> diets;
  final Set<Allergy> allergies;
  final Set<AvoidFood> avoids;
  final Set<String> friesLikes;
  final Set<String> friesDislikes;

  const TasteProfile({
    required this.flavors,
    required this.cuisines,
    required this.budget,
    required this.diets,
    required this.allergies,
    required this.avoids,
    this.friesLikes = const <String>{},
    this.friesDislikes = const <String>{},
  });

  factory TasteProfile.empty() => const TasteProfile(
        flavors: {},
        cuisines: {},
        budget: null,
        diets: {},
        allergies: {},
        avoids: {},
        friesLikes: {},
        friesDislikes: {},
      );

  static String _enumName(Object e) {
    final s = e.toString(); // e.g. "DietType.vegan"
    final i = s.indexOf(".");
    return i >= 0 ? s.substring(i + 1) : s;
  }

  Map<String, dynamic> toJson() => {
        "flavors": flavors.toList(),
        "cuisines": cuisines.toList(),
        "budget": budget,
        "diets": diets.map(_enumName).toList(),
        "allergies": allergies.map(_enumName).toList(),
        "avoids": avoids.map(_enumName).toList(),
        "friesLikes": friesLikes.toList(),
        "friesDislikes": friesDislikes.toList(),
      };

  factory TasteProfile.fromJson(Map<String, dynamic>? j) {
    if (j == null) return TasteProfile.empty();

    Set<String> asStringSet(String key) =>
        ((j[key] as List?) ?? const <dynamic>[])
            .whereType<String>()
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toSet();

    T? enumFrom<T>(String name, List<T> values) {
      for (final v in values) {
        if (_enumName(v!) == name) return v;
      }
      return null;
    }

    Set<T> enumSet<T>(String key, List<T> values) {
      final out = <T>{};
      final raw = (j[key] as List?) ?? const <dynamic>[];
      for (final x in raw) {
        if (x is String) {
          final v = enumFrom<T>(x, values);
          if (v != null) out.add(v);
        }
      }
      return out;
    }

    return TasteProfile(
      flavors: asStringSet("flavors"),
      cuisines: asStringSet("cuisines"),
      budget: j["budget"] is String ? (j["budget"] as String) : null,
      diets: enumSet<DietType>("diets", DietType.values),
      allergies: enumSet<Allergy>("allergies", Allergy.values),
      avoids: enumSet<AvoidFood>("avoids", AvoidFood.values),
      friesLikes: asStringSet("friesLikes"),
      friesDislikes: asStringSet("friesDislikes"),
    );
  }
}
