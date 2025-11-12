import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:similar_eats_desktop/main.dart' as app;

Future<void> _scrollIntoView(WidgetTester tester, Finder f) async {
  if (f.evaluate().isNotEmpty) return;
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(f, 250, scrollable: scrollables.first);
    await tester.pumpAndSettle();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dinner tile shows SnackBar on Home OR navigates on Welcome', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // App rendered
    expect(find.text('Similar Eats'), findsWidgets);

    // Prefer keyed Home tile; fall back to text on Welcome.
    Finder dinnerTile = find.byKey(const Key('home-dinner'));
    if (dinnerTile.evaluate().isEmpty) {
      dinnerTile = find.text('Find spots that match me');
    }

    await _scrollIntoView(tester, dinnerTile);
    expect(dinnerTile, findsWidgets, reason: 'Dinner tile should be present on Home/Welcome');

    await tester.tap(dinnerTile.first);

    // Let outcomes occur.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Outcome A: SnackBar (HomeScreen variant)
    final snackByKey = find.byKey(const Key('snack-recs'));
    final snackByText = find.text('Recommendations coming soon');
    final sawSnack = snackByKey.evaluate().isNotEmpty || snackByText.evaluate().isNotEmpty;

    // Outcome B: Navigation (WelcomeScreen -> DinnerScreen): look for a Back button.
    final sawBack = find.byTooltip('Back').evaluate().isNotEmpty ||
        find.byIcon(Icons.arrow_back).evaluate().isNotEmpty;

    expect(sawSnack || sawBack, true,
        reason: 'Expected SnackBar on Home OR navigation (e.g., to Dinner screen) on Welcome.');
  });
}
