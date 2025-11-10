import "package:flutter_test/flutter_test.dart";
import "package:similar_eats_desktop/features/taste_quiz/domain/taste_profile.dart";

void main() {
  test("badge selection works", () {
    expect(
        computeBadge(const TasteProfile(
                sweet: 5, salty: 1, sour: 1, spicy: 1, umami: 1))
            .label,
        "Sweet Tooth");
    expect(
        computeBadge(const TasteProfile(
                spicy: 5, sweet: 1, salty: 1, sour: 1, umami: 1))
            .label,
        "Spice Chaser");
  });
}
