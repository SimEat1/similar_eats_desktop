import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:similar_eats_desktop/main.dart" as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Home shows snackbars for placeholders", (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // "Find spots that match me" -> snackbar
    await tester.tap(find.text("Find spots that match me"));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text("Recommendations coming soon"), findsOneWidget);

    // "Explore map" -> snackbar
    await tester.tap(find.text("Explore map"));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text("Explore map placeholder"), findsOneWidget);
  });
}
