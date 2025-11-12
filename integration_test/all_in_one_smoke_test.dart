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

  testWidgets('Boot + Home sanity + Try List + Receipts + Dinner', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Home visible
    expect(find.text('Similar Eats'), findsWidgets);

    // Dinner: allow snackbar or nav (Home vs Welcome variants)
    Finder dinnerTile = find.byKey(const Key('home-dinner'));
    if (dinnerTile.evaluate().isEmpty) {
      dinnerTile = find.text('Find spots that match me');
    }
    await _scrollIntoView(tester, dinnerTile);
    await tester.tap(dinnerTile.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final sawSnack = find.byKey(const Key('snack-recs')).evaluate().isNotEmpty ||
        find.text('Recommendations coming soon').evaluate().isNotEmpty;
    final sawBack = find.byTooltip('Back').evaluate().isNotEmpty ||
        find.byIcon(Icons.arrow_back).evaluate().isNotEmpty;
    expect(sawSnack || sawBack, true);

    // Back if navigated
    if (sawBack) {
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // Try list opens
    Finder tryListTile = find.byKey(const Key('home-try-list'));
    if (tryListTile.evaluate().isEmpty) {
      tryListTile = find.text('Try list');
    }
    await _scrollIntoView(tester, tryListTile);
    await tester.tap(tryListTile.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Try List'), findsOneWidget);

    // Back to Home
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Receipts: Scan receipt opens then back
    final scanTile = find.text('Scan receipt');
    await _scrollIntoView(tester, scanTile);
    await tester.tap(scanTile.first);
    await tester.pumpAndSettle(const Duration(seconds: 2));
    final onScan = find.text('Scan Receipt').evaluate().isNotEmpty ||
        find.text('Scan receipt').evaluate().isNotEmpty ||
        find.textContaining('Scan').evaluate().isNotEmpty ||
        find.byType(TextField).evaluate().isNotEmpty;
    expect(onScan, true);
    await tester.pageBack();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Final sanity
    expect(find.text('Similar Eats'), findsWidgets);
  });
}
