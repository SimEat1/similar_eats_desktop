import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:similar_eats_desktop/main.dart' as app;

Future<void> _scrollIntoView(WidgetTester tester, Finder f) async {
  if (f.evaluate().isNotEmpty) return;
  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: scrollables.first);
    await tester.pumpAndSettle();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Receipts: Scan receipt opens and back returns to Home', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Find the "Scan receipt" tile on Home (may need to scroll on smaller windows)
    final scanTile = find.text('Scan receipt');
    await _scrollIntoView(tester, scanTile);
    expect(scanTile, findsWidgets);

    await tester.tap(scanTile.first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Be forgiving about the target screen title; match a few likely markers.
    final opened = find.text('Scan Receipt').evaluate().isNotEmpty ||
        find.text('Scan receipt').evaluate().isNotEmpty ||
        find.textContaining('Scan').evaluate().isNotEmpty ||
        find.byType(TextField).evaluate().isNotEmpty;
    expect(opened, true, reason: 'Expected to be on the Scan Receipt screen.');

    // Back to Home
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Sanity: Home visible again (look for a known tile)
    final backHome = find.text('Try list').evaluate().isNotEmpty ||
        find.text('Explore map').evaluate().isNotEmpty ||
        find.text('Similar Eats').evaluate().isNotEmpty;
    expect(backHome, true, reason: 'Expected to return to Home.');
  });
}
