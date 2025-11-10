import 'package:similar_eats_desktop/features/profile/models/taste_profile.dart';
import 'package:similar_eats_desktop/features/dinner/restaurant_repository.dart';

class ScoredRestaurant {
  final RestaurantLite r;
  final double score; // 0..1
  final List<String> reasons; // short human-readable reasons
  const ScoredRestaurant(this.r, this.score, this.reasons);
}

class DinnerMatcher {
  static List<ScoredRestaurant> recommend({
    required TasteProfile profile,
    required List<RestaurantLite> candidates,
    String? category, // e.g. "steak" or "fries"
    int limit = 20,
  }) {
    final out = <ScoredRestaurant>[];

    for (final r in candidates) {
      // 1) Category gate (if user picked one)
      if (category != null &&
          category.isNotEmpty &&
          !r.categories.contains(category.toLowerCase())) {
        continue;
      }

      // 2) Hard filters: allergies & avoids
      if (profile.allergies.isNotEmpty &&
          r.unsafeAllergens
              .map((e) => e.toLowerCase())
              .toSet()
              .intersection(
                  profile.allergies.map((e) => e.name.toLowerCase()).toSet())
              .isNotEmpty) {
        continue;
      }

      final avoids = profile.avoids.map((e) => e.name.toLowerCase()).toSet();
      if (avoids.isNotEmpty && r.proteins.intersection(avoids).isNotEmpty) {
        continue;
      }

      // Strict diets (basic sample; extend as needed)
      final diets = profile.diets.map((e) => e.name.toLowerCase()).toSet();
      final requireVegan = diets.contains("vegan");
      final requireVegetarian = diets.contains("vegetarian") && !requireVegan;
      final requireHalal = diets.contains("halal");
      final requireKosher = diets.contains("kosher");

      if (requireVegan && !r.supportsDiets.contains("vegan")) continue;
      if (requireVegetarian && !r.supportsDiets.contains("vegetarian")) {
        continue;
      }
      if (requireHalal && !r.supportsDiets.contains("halal")) continue;
      if (requireKosher && !r.supportsDiets.contains("kosher")) continue;

      // 3) Soft scoring: cuisines / flavors overlap; budget nudge; category bonus
      double jaccard(Set<String> a, Set<String> b) {
        if (a.isEmpty && b.isEmpty) return 1.0;
        final inter = a.intersection(b).length;
        final uni = a.union(b).length;
        return uni == 0 ? 0 : inter / uni;
      }

      final userCuisines = profile.cuisines.map((e) => e.toLowerCase()).toSet();
      final userFlavors = profile.flavors.map((e) => e.toLowerCase()).toSet();

      final cScore = jaccard(userCuisines, r.cuisines);
      final fScore = jaccard(userFlavors, r.flavors);

      double score = 0.6 * cScore + 0.4 * fScore;
      if (category != null && category.isNotEmpty) {
        score += 0.1; // category bonus
      }
      if (profile.budget != null && profile.budget == r.budget) {
        score += 0.05; // small budget nudge
      }

      // 4) Fries micro-prefs: bonus for likes, penalty for dislikes
      final likeFries = profile.friesLikes.map((e) => e.toLowerCase()).toSet();
      final dislikeFries =
          profile.friesDislikes.map((e) => e.toLowerCase()).toSet();
      final rFries = r.friesStyles.map((e) => e.toLowerCase()).toSet();

      // If user explicitly chose the "fries" category, block restaurants with disliked fries.
      if ((category ?? "") == "fries" &&
          rFries.intersection(dislikeFries).isNotEmpty) {
        continue;
      }

      if (rFries.isNotEmpty && likeFries.isNotEmpty) {
        final inter = rFries.intersection(likeFries).length;
        score += 0.15 * (inter / likeFries.length);
      }
      if (rFries.isNotEmpty && dislikeFries.isNotEmpty) {
        final interD = rFries.intersection(dislikeFries).length;
        if (interD > 0) score -= 0.25 * (interD / dislikeFries.length);
      }

      // Clamp score
      score = score.clamp(0.0, 1.0);

      // Reasons
      final reasons = <String>[];
      if (userCuisines.isNotEmpty) {
        final m = userCuisines.intersection(r.cuisines);
        if (m.isNotEmpty) reasons.add("Cuisines: ${m.join(", ")}");
      }
      if (userFlavors.isNotEmpty) {
        final m = userFlavors.intersection(r.flavors);
        if (m.isNotEmpty) reasons.add("Flavors: ${m.join(", ")}");
      }
      if (profile.budget == r.budget) reasons.add("Budget match: ${r.budget}");
      if (likeFries.isNotEmpty) {
        final lf = rFries.intersection(likeFries);
        if (lf.isNotEmpty) reasons.add("Fries you like: ${lf.join(", ")}");
      }
      if (dislikeFries.isNotEmpty) {
        final df = rFries.intersection(dislikeFries);
        if (df.isNotEmpty) reasons.add("Fries to avoid: ${df.join(", ")}");
      }

      out.add(ScoredRestaurant(r, score, reasons));
    }

    out.sort((a, b) => b.score.compareTo(a.score));
    return out.take(limit).toList();
  }
}
