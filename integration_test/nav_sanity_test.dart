import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:similar_eats_desktop/main.dart' as app;

/// Polling helper: waits until [predicate] is true or times out.
Future<void> _waitUntil(
  WidgetTester tester,
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 10),
  Duration step = const Duration(milliseconds: 200),
}) async {
  final sw = Stopwatch()..start();
  while (!predicate()) {
    if (sw.elapsed >= timeout) break;
    await tester.pump(step);
  }
}

/// Finds and taps a back action in as many ways as possible.
Future<void> _goBack(WidgetTester tester) async {
  final backByTooltip = find.byTooltip('Back');
  final backByIcon = find.byIcon(Icons.arrow_back);
  if (backByTooltip.evaluate().isNotEmpty) {
    await tester.tap(backByTooltip.first);
  } else if (backByIcon.evaluate().isNotEmpty) {
    await tester.tap(backByIcon.first);
  } else {
    // Try keyboard back (ESC) on desktop
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
  }
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

/// Scrolls any scrollable parent until [text] is visible (if possible).
Future<void> _scrollTextIntoView(WidgetTester tester, String text) async {
  if (find.text(text).evaluate().isNotEmpty) return;

  final scrollables = find.byType(Scrollable);
  if (scrollables.evaluate().isNotEmpty) {
    await tester.scrollUntilVisible(
      find.text(text),
      200,
      scrollable: scrollables.first,
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Try list opens and back works; Explore map tap is handled',
      (tester) async {
    app.main();

    // Give boot plenty of time.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Consider "Home" ready when we can see either main tile text.
    await _waitUntil(
      tester,
      () => find.text('Try list').evaluate().isNotEmpty ||
            find.text('Explore map').evaluate().isNotEmpty,
      timeout: const Duration(seconds: 10),
    );

    // Open Try list (scroll if needed)
    await _scrollTextIntoView(tester, 'Try list');
    expect(find.text('Try list'), findsWidgets);
    await tester.tap(find.text('Try list').first);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // We should now be on the Try List screen.
    expect(find.text('Try List'), findsOneWidget);

    // Navigate back to Home.
    await _goBack(tester);

    // Home is considered ready once tiles are visible again.
    await _waitUntil(
      tester,
      () => find.text('Try list').evaluate().isNotEmpty ||
            find.text('Explore map').evaluate().isNotEmpty,
      timeout: const Duration(seconds: 8),
    );

    // Tap Explore map (placeholder handler) — just ensure it doesn't crash or navigate away.
    await _scrollTextIntoView(tester, 'Explore map');
    expect(find.text('Explore map'), findsWidgets);
    await tester.tap(find.text('Explore map').first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Still on Home (tiles still present).
    expect(
      find.text('Try list').evaluate().isNotEmpty ||
      find.text('Explore map').evaluate().isNotEmpty,
      true,
      reason: 'Expected to remain on Home after tapping Explore map placeholder.',
    );
  });
}






