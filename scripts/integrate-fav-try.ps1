param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Integrate Favorites + Try List into app boot and routes ==" -ForegroundColor Cyan
Set-Location $ProjectRoot

# 0) Safety: make sure core files we generated exist
$req = @(
  "lib/features/favorites/presentation/favorites_controller.dart",
  "lib/features/favorites/presentation/favorites_screen.dart",
  "lib/features/favorites/data/favorites_store.dart",
  "lib/features/try_list/presentation/try_list_controller.dart",
  "lib/features/try_list/presentation/try_list_screen.dart",
  "lib/features/try_list/data/try_list_store.dart"
)
$missing = $req | Where-Object { -not (Test-Path $_) }
if ($missing.Count -gt 0) {
  Write-Host "  ! Missing required files:" -ForegroundColor Red
  $missing | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
  Write-Host "  -> Run scripts\\add-favorites-trylist.ps1 first." -ForegroundColor Yellow
  exit 1
}

# 1) Create a bootstrap wrapper for providers so we don't fight your existing runApp
$bootstrap = @"
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'features/favorites/data/favorites_store.dart';
import 'features/favorites/presentation/favorites_controller.dart';
import 'features/try_list/data/try_list_store.dart';
import 'features/try_list/presentation/try_list_controller.dart';

Widget withAppProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => FavoritesController(FavoritesStore())..init()),
      ChangeNotifierProvider(create: (_) => TryListController(TryListStore())..init()),
    ],
    child: child,
  );
}
"@
$bootstrap | Set-Content -Encoding UTF8 .\lib\bootstrap_providers.dart
Write-Host "  ✓ wrote lib/bootstrap_providers.dart" -ForegroundColor Green

# 2) Patch main.dart and/or main_demo.dart: wrap runApp(..) -> runApp(withAppProviders(..))
$mainFiles = @("lib\main.dart","lib\main_demo.dart") | Where-Object { Test-Path $_ }
foreach ($mf in $mainFiles) {
  $raw = Get-Content -Raw -Path $mf

  # add import if missing
  $import = "import 'bootstrap_providers.dart';"
  if ($raw -notmatch [regex]::Escape($import)) {
    if ($raw -match "^(import\s+['""][^;]+['""];\s*)+") {
      $raw = $raw -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
    } else {
      $raw = $import + "`r`n" + $raw
    }
  }

  # wrap runApp(...) with withAppProviders(...)
  # covers runApp(const MyApp());, runApp(MyApp());, runApp(MaterialApp(...));
  $raw = [regex]::Replace($raw, "runApp\(\s*(?<inner>[^;]+)\s*\);", { param($m) "runApp(withAppProviders(" + $m.Groups['inner'].Value + "));" })

  # add imports for screens, for route patch below
  $needImports = @(
    "import 'features/favorites/presentation/favorites_screen.dart';",
    "import 'features/try_list/presentation/try_list_screen.dart';"
  )
  foreach ($ni in $needImports) {
    if ($raw -notmatch [regex]::Escape($ni)) {
      if ($raw -match "^(import\s+['""][^;]+['""];\s*)+") {
        $raw = $raw -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $ni + "`r`n")
      } else {
        $raw = $ni + "`r`n" + $raw
      }
    }
  }

  # 3) Best-effort route injection: if MaterialApp has routes: { ... }, append our two routes.
  # If no routes:, add one.
  $addedRoutes = "FavoritesScreen.route: (_) => const FavoritesScreen(), TryListScreen.route: (_) => const TryListScreen(),"

  if ($raw -match "MaterialApp\s*\(") {
    if ($raw -match "routes\s*:\s*{") {
      # append into existing map right after the opening brace
      $raw = [regex]::Replace($raw, "routes\s*:\s*{", "routes: { $addedRoutes ", 1)
    } else {
      # try to inject routes: ... after title:/home:/theme: if present, else immediately after '('
      $raw = [regex]::Replace($raw, "MaterialApp\s*\(", "MaterialApp(" + "routes: { $addedRoutes }, ", 1)
    }
  }

  Set-Content -Encoding UTF8 -Path $mf -Value $raw
  Write-Host "  ✓ patched $mf" -ForegroundColor Green
}

# 4) Tiny menu tip (optional) -> create a snippet file
@"
/* ===== Optional: quick entry points =====
Add to any AppBar actions or a Drawer to navigate:
IconButton(
  icon: const Icon(Icons.favorite),
  tooltip: 'Favorites',
  onPressed: () => Navigator.of(context).pushNamed(FavoritesScreen.route),
),
IconButton(
  icon: const Icon(Icons.bookmark_add_outlined),
  tooltip: 'Try List',
  onPressed: () => Navigator.of(context).pushNamed(TryListScreen.route),
),
*/
"@ | Set-Content -Encoding UTF8 .\lib\features\favorites\INTEGRATION_SNIPPETS_MENU.txt
Write-Host "  ✓ wrote INTEGRATION_SNIPPETS_MENU.txt" -ForegroundColor Green

Write-Host "`nDone. Next:" -ForegroundColor Cyan
Write-Host "  1) flutter test test/favorites_trylist_store_test.dart" -ForegroundColor Yellow
Write-Host "  2) flutter run -d windows" -ForegroundColor Yellow
Write-Host "  3) In the app, open a restaurant, tap 'Save to Favorites' / 'Add to Try List'" -ForegroundColor Yellow
Write-Host "  4) Navigate to Favorites / Try List via menu buttons you add (see snippet)" -ForegroundColor Yellow
