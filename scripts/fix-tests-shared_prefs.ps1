param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Fix tests for SharedPreferences ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

$tf = "test/favorites_trylist_store_test.dart"

@"
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:similar_eats_desktop/features/favorites/data/favorites_store.dart';
import 'package:similar_eats_desktop/features/try_list/data/try_list_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // Touch instance once so the legacy binding is ready.
    await SharedPreferences.getInstance();
  });

  test('favorites toggle add/remove', () async {
    final store = FavoritesStore();
    await store.toggle('r1'); // add
    var ids = await store.loadIds();
    expect(ids.contains('r1'), true);

    await store.toggle('r1'); // remove
    ids = await store.loadIds();
    expect(ids.contains('r1'), false);
  });

  test('try list toggle add/remove', () async {
    final store = TryListStore();
    await store.toggle('r2'); // add
    var ids = await store.loadIds();
    expect(ids.contains('r2'), true);

    await store.toggle('r2'); // remove
    ids = await store.loadIds();
    expect(ids.contains('r2'), false);
  });
}
"@ | Set-Content -Encoding UTF8 $tf

Write-Host "  ✓ Wrote $tf" -ForegroundColor Green
