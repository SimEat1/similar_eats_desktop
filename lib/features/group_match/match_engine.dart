import "dart:math";
import "package:latlong2/latlong.dart";

/// === Data models (can later be sourced from Firestore) ===

class UserPrefs {
  final Set<String> cuisines;
  final Set<String> flavors;

  /// Example: vegan, vegetarian, halal, kosher, keto...
  final Set<String> diets;

  /// Example: peanut, treenut, shellfish, egg, dairy, gluten, soy...
  final Set<String> allergies;

  const UserPrefs({
    required this.cuisines,
    required this.flavors,
    required this.diets,
    required this.allergies,
  });
}

class Restaurant {
  final String id;
  final String name;
  final double lat;
  final double lng;

  /// Tags describing the place
  final Set<String> cuisines; // e.g., italian, mexican
  final Set<String> flavors; // e.g., spicy, savory
  final Set<String> supportsDiets; // e.g., vegan, vegetarian, halal
  /// Allergens that may be present (best-effort metadata)
  final Set<String> unsafeAllergens;

  const Restaurant({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.cuisines,
    required this.flavors,
    required this.supportsDiets,
    required this.unsafeAllergens,
  });
}

/// === Group matchmaking ===
class GroupMatcher {
  static final Distance _dist = const Distance();

  /// Recommends restaurants inside [radiusMeters] of [centerLat]/[centerLng],
  /// filtering by the **strictest** group diet & the **union** of allergies,
  /// then scoring by cuisines/flavors overlap + light distance penalty.
  static List<Restaurant> recommend({
    required List<UserPrefs> users,
    required List<Restaurant> candidates,
    required double centerLat,
    required double centerLng,
    required double radiusMeters,
    int limit = 10,
  }) {
    // Strictest diet across group
    final requireVegan = users.any((u) => u.diets.contains("vegan"));
    final requireVegetarian =
        !requireVegan && users.any((u) => u.diets.contains("vegetarian"));
    final requireHalal = users.any((u) => u.diets.contains("halal"));
    final requireKosher = users.any((u) => u.diets.contains("kosher"));

    // Union of allergies (avoid all)
    final Set<String> avoidAllergens = {
      for (final u in users) ...u.allergies.map((e) => e.toLowerCase())
    };

    final center = LatLng(centerLat, centerLng);

    // 1) Filter by distance + constraints
    final filtered = candidates.where((r) {
      final meters = _dist.distance(LatLng(r.lat, r.lng), center);
      if (meters > radiusMeters) return false;

      if (requireVegan && !r.supportsDiets.contains("vegan")) return false;
      if (requireVegetarian && !r.supportsDiets.contains("vegetarian")) {
        return false;
      }
      if (requireHalal && !r.supportsDiets.contains("halal")) return false;
      if (requireKosher && !r.supportsDiets.contains("kosher")) return false;

      if (avoidAllergens.isNotEmpty &&
          r.unsafeAllergens
              .map((e) => e.toLowerCase())
              .toSet()
              .intersection(avoidAllergens)
              .isNotEmpty) {
        return false;
      }
      return true;
    }).toList();

    double jaccard(Set<String> a, Set<String> b) {
      if (a.isEmpty && b.isEmpty) return 1.0;
      final inter = a.intersection(b).length;
      final uni = a.union(b).length;
      return uni == 0 ? 0 : inter / uni;
    }

    // 2) Score by average( per-user (0.6*cuisine + 0.4*flavor) ) with mild distance penalty
    final scored = <(Restaurant r, double score)>[];
    for (final r in filtered) {
      final perUser = <double>[];
      for (final u in users) {
        final c = jaccard(
          u.cuisines.map((e) => e.toLowerCase()).toSet(),
          r.cuisines.map((e) => e.toLowerCase()).toSet(),
        );
        final f = jaccard(
          u.flavors.map((e) => e.toLowerCase()).toSet(),
          r.flavors.map((e) => e.toLowerCase()).toSet(),
        );
        perUser.add(0.6 * c + 0.4 * f);
      }
      final base = perUser.isEmpty
          ? 0
          : perUser.reduce((a, b) => a + b) / perUser.length;

      // light distance penalty (up to -0.2 at the edge of radius)
      final meters = _dist.distance(LatLng(r.lat, r.lng), center);
      final distPenalty = 0.2 * min(1.0, meters / radiusMeters);
      final finalScore = (base * (1.0 - distPenalty)).clamp(0.0, 1.0);
      scored.add((r, finalScore));
    }

    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(limit).map((e) => e.$1).toList();
  }
}
