import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:similar_eats_desktop/features/recommendations/domain/restaurant.dart";
import "package:similar_eats_desktop/features/recommendations/presentation/restaurant_detail_screen.dart";

void main() {
  testWidgets("detail shows name and cuisine", (tester) async {
    final r = Restaurant(
      id: "x", name: "Test Place", cuisine: "Test Cuisine",
      tasteVector: const [1,2,3,4,5], tags: const ["alpha","beta"]
    );

    await tester.pumpWidget(MaterialApp(
      routes: { RestaurantDetailScreen.route: (_) => const RestaurantDetailScreen() },
      home: const SizedBox.shrink(), // start on a blank page
    ));

    // Push the detail route with arguments
    Navigator.of(tester.element(find.byType(SizedBox))).pushNamed(
      RestaurantDetailScreen.route,
      arguments: r,
    );

    await tester.pumpAndSettle();

    expect(find.text("Test Place"), findsOneWidget);
    expect(find.text("Test Cuisine"), findsOneWidget);
  });
}
