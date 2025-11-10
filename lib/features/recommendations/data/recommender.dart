import 'package:similar_eats_desktop/features/taste_quiz/domain/taste_profile.dart';
import 'package:similar_eats_desktop/features/recommendations/domain/restaurant.dart';
import 'dart:math';

double _cosine(List<double> a, List<double> b) {
  double dot = 0, na = 0, nb = 0;
  for (var i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }
  final denom = sqrt(na) * sqrt(nb);
  if (denom == 0) return 0;
  return dot / denom;
}

class ScoredRestaurant {
  final Restaurant restaurant;
  final double score; // 0..1
  const ScoredRestaurant(this.restaurant, this.score);
}

class Recommender {
  List<ScoredRestaurant> recommend({
    required TasteProfile profile,
    required List<Restaurant> candidates,
    int topN = 20,
  }) {
    final user = profile.asVector();
    final scored = candidates
        .map((r) => ScoredRestaurant(r, _cosine(user, r.tasteVector)))
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    if (topN <= 0 || topN >= scored.length) return scored;
    return scored.sublist(0, topN);
  }
}
