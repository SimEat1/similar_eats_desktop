import "package:flutter_test/flutter_test.dart";
import "package:similar_eats_desktop/features/taste_quiz/domain/taste_profile.dart";
import "package:similar_eats_desktop/features/recommendations/data/mock_restaurants.dart";
import "package:similar_eats_desktop/features/recommendations/data/recommender.dart";

void main() {
  test("recommender ranks spicy places higher for spicy profile", () {
    final spicy = const TasteProfile(sweet:1, salty:1.5, sour:1, spicy:5, umami:2.5);
    final recs = Recommender().recommend(profile: spicy, candidates: MockRestaurants.all, topN: 5);
    expect(recs.isNotEmpty, true);
    final top = recs.first.restaurant.cuisine.toLowerCase();
    expect(top.contains("thai") || top.contains("mexican") || top.contains("bbq"), true);
  });
}
