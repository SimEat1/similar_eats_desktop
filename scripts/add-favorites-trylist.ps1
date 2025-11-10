param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Add Favorites + Try List (local) ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

# Ensure dirs
$dirs = @(
  "lib/features/favorites",
  "lib/features/favorites/data",
  "lib/features/favorites/presentation",
  "lib/features/try_list",
  "lib/features/try_list/data",
  "lib/features/try_list/presentation",
  "lib/core/platform",
  "test"
)
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }

# Ensure deps
flutter pub add shared_preferences provider | Out-Null

# Favorites store + controller
@"
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStore {
  static const _k = 'favorites_ids_v1';

  Future<Set<String>> loadIds() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? const [];
    return list.toSet();
  }

  Future<void> _saveIds(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_k, ids.toList());
  }

  Future<Set<String>> toggle(String id) async {
    final ids = await loadIds();
    if (ids.contains(id)) { ids.remove(id); } else { ids.add(id); }
    await _saveIds(ids);
    return ids;
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/favorites/data/favorites_store.dart

@"
import 'package:flutter/foundation.dart';
import '../data/favorites_store.dart';

class FavoritesController extends ChangeNotifier {
  final FavoritesStore _store;
  FavoritesController(this._store);

  Set<String> ids = {};

  Future<void> init() async {
    ids = await _store.loadIds();
    notifyListeners();
  }

  bool isFavorite(String id) => ids.contains(id);

  Future<void> toggle(String id) async {
    ids = await _store.toggle(id);
    notifyListeners();
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/favorites/presentation/favorites_controller.dart

# Try List store + controller
@"
import 'package:shared_preferences/shared_preferences.dart';

class TryListStore {
  static const _k = 'trylist_ids_v1';

  Future<Set<String>> loadIds() async {
    final sp = await SharedPreferences.getInstance();
    final list = sp.getStringList(_k) ?? const [];
    return list.toSet();
  }

  Future<void> _saveIds(Set<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_k, ids.toList());
  }

  Future<Set<String>> toggle(String id) async {
    final ids = await loadIds();
    if (ids.contains(id)) { ids.remove(id); } else { ids.add(id); }
    await _saveIds(ids);
    return ids;
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/try_list/data/try_list_store.dart

@"
import 'package:flutter/foundation.dart';
import '../data/try_list_store.dart';

class TryListController extends ChangeNotifier {
  final TryListStore _store;
  TryListController(this._store);

  Set<String> ids = {};

  Future<void> init() async {
    ids = await _store.loadIds();
    notifyListeners();
  }

  bool contains(String id) => ids.contains(id);

  Future<void> toggle(String id) async {
    ids = await _store.toggle(id);
    notifyListeners();
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/try_list/presentation/try_list_controller.dart

# Favorites screen (lists saved restaurants; uses MockRestaurants for now)
@"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../recommendations/data/mock_restaurants.dart';
import '../../recommendations/domain/restaurant.dart';
import '../../recommendations/presentation/restaurant_detail_screen.dart';
import '../presentation/favorites_controller.dart';

class FavoritesScreen extends StatelessWidget {
  static const route = '/favorites';
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FavoritesController>();
    final all = MockRestaurants.all;
    final favs = all.where((r) => ctrl.ids.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favs.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final Restaurant r = favs[i];
                return Dismissible(
                  key: ValueKey(r.id),
                  background: Container(color: Theme.of(context).colorScheme.error),
                  onDismissed: (_) => context.read<FavoritesController>().toggle(r.id),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    title: Text(r.name),
                    subtitle: Text(r.cuisine),
                    onTap: () => Navigator.of(context).pushNamed(
                      RestaurantDetailScreen.route,
                      arguments: r,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/favorites/presentation/favorites_screen.dart

# Try List screen
@"
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../recommendations/data/mock_restaurants.dart';
import '../../recommendations/domain/restaurant.dart';
import '../../recommendations/presentation/restaurant_detail_screen.dart';
import '../presentation/try_list_controller.dart';

class TryListScreen extends StatelessWidget {
  static const route = '/tryList';
  const TryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TryListController>();
    final all = MockRestaurants.all;
    final list = all.where((r) => ctrl.ids.contains(r.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Try List')),
      body: list.isEmpty
          ? const Center(child: Text('Your Try List is empty'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final Restaurant r = list[i];
                return Dismissible(
                  key: ValueKey(r.id),
                  background: Container(color: Theme.of(context).colorScheme.error),
                  onDismissed: (_) => context.read<TryListController>().toggle(r.id),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    title: Text(r.name),
                    subtitle: Text(r.cuisine),
                    onTap: () => Navigator.of(context).pushNamed(
                      RestaurantDetailScreen.route,
                      arguments: r,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
"@ | Set-Content -Encoding UTF8 lib/features/try_list/presentation/try_list_screen.dart

# Best-effort auto-patch Restaurant Detail to add buttons (favorite/try)
$detailPath = "lib/features/recommendations/presentation/restaurant_detail_screen.dart"
if (Test-Path $detailPath) {
  $d = Get-Content -Raw -Path $detailPath

  # Ensure imports
  if ($d -notmatch "favorites_controller.dart") {
    $d = $d -replace 'import "../domain/restaurant.dart";',
      'import "../domain/restaurant.dart";
import "../../favorites/presentation/favorites_controller.dart";
import "../../try_list/presentation/try_list_controller.dart";
import "package:provider/provider.dart";'
  }

  # Replace the single FilledButton with two toggles
  $d = $d -replace 'FilledButton\([\s\S]*?Save to Favorites[\s\S]*?\),', @"
Row(
  children: [
    Expanded(
      child: Consumer<FavoritesController>(
        builder: (_, fav, __) {
          final isFav = fav.isFavorite(r.id);
          return FilledButton.icon(
            onPressed: () async {
              await fav.toggle(r.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isFav ? "Removed from Favorites" : "Saved to Favorites")),
                );
              }
            },
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            label: Text(isFav ? "Favorited" : "Save to Favorites"),
          );
        },
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Consumer<TryListController>(
        builder: (_, t, __) {
          final inList = t.contains(r.id);
          return OutlinedButton.icon(
            onPressed: () async {
              await t.toggle(r.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(inList ? "Removed from Try List" : "Added to Try List")),
                );
              }
            },
            icon: Icon(inList ? Icons.check : Icons.add),
            label: Text(inList ? "In Try List" : "Add to Try List"),
          );
        },
      ),
    ),
  ],
),
"@

  Set-Content -Encoding UTF8 -Path $detailPath -Value $d
  Write-Host "  ~ Patched $detailPath with Favorites/Try buttons" -ForegroundColor Yellow
} else {
  Write-Host "  = Detail screen not found; skipping button patch (see integration snippet)" -ForegroundColor DarkGray
}

# Tiny test for stores
@"
import 'package:flutter_test/flutter_test.dart';
import 'package:similar_eats_desktop/features/favorites/data/favorites_store.dart';
import 'package:similar_eats_desktop/features/try_list/data/try_list_store.dart';

void main() {
  test('favorites toggle add/remove', () async {
    final s = FavoritesStore();
    final a = await s.toggle('r1');
    expect(a.contains('r1'), true);
    final b = await s.toggle('r1');
    expect(b.contains('r1'), false);
  });

  test('try list toggle add/remove', () async {
    final s = TryListStore();
    final a = await s.toggle('r2');
    expect(a.contains('r2'), true);
    final b = await s.toggle('r2');
    expect(b.contains('r2'), false);
  });
}
"@ | Set-Content -Encoding UTF8 test/favorites_trylist_store_test.dart

# Integration snippet (providers + routes + nav examples)
@"
/* ===== Add to your root (e.g., main.dart) =====
import 'package:provider/provider.dart';
import 'features/favorites/data/favorites_store.dart';
import 'features/favorites/presentation/favorites_controller.dart';
import 'features/try_list/data/try_list_store.dart';
import 'features/try_list/presentation/try_list_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesController(FavoritesStore())..init()),
        ChangeNotifierProvider(create: (_) => TryListController(TryListStore())..init()),
        // existing providers...
      ],
      child: const MyApp(),
    ),
  );
}

import 'features/favorites/presentation/favorites_screen.dart';
import 'features/try_list/presentation/try_list_screen.dart';

MaterialApp(
  routes: {
    FavoritesScreen.route: (_) => const FavoritesScreen(),
    TryListScreen.route: (_) => const TryListScreen(),
    // existing routes...
  },
);

/// From anywhere (e.g., app bar menu):
// Navigator.of(context).pushNamed(FavoritesScreen.route);
// Navigator.of(context).pushNamed(TryListScreen.route);
*/
"@ | Set-Content -Encoding UTF8 lib/features/favorites/INTEGRATION_SNIPPETS_FAV_TRY.txt

Write-Host "`nFiles written." -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Green
Write-Host "  1) Add providers + routes (see lib/features/favorites/INTEGRATION_SNIPPETS_FAV_TRY.txt)" -ForegroundColor Yellow
Write-Host "  2) Verify Restaurant Detail shows Favorites + Try List buttons" -ForegroundColor Yellow
Write-Host "  3) Run tests:  flutter test test/favorites_trylist_store_test.dart" -ForegroundColor Yellow
Write-Host "  4) Run app:    flutter run -d windows" -ForegroundColor Yellow
