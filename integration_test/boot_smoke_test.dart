import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:similar_eats_desktop/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App boots to Home and shows Try list tile', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Similar Eats'), findsOneWidget);
    expect(find.text('Try list'), findsOneWidget);
  });
}
