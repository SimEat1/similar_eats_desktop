Write-Host "== Map FAB -> Recommendations ==" -ForegroundColor Cyan

$map = "lib/features/explore/explore_map_screen.dart"
if (-not (Test-Path $map)) { Write-Host "  ! $map not found" -ForegroundColor Red; exit 1 }

$t = Get-Content -Raw $map

# Ensure import
$imp = "import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';"
if ($t -notmatch [regex]::Escape($imp)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $imp + \"`r`n\")
  } else { $t = $imp + \"`r`n\" + $t }
}

# Replace the existing FloatingActionButton onPressed with a small menu
$t = [regex]::Replace(
  $t,
  "FloatingActionButton\([^\)]*onPressed:\s*\(\)\s*=>\s*[^\),]+\)",
  @"
FloatingActionButton(
  child: const Icon(Icons.add),
  onPressed: () async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Show matches list'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(RecommendationsScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }
)
"@,
  1
)

Set-Content -Encoding UTF8 $map $t
Write-Host "  ✓ Patched explore_map_screen.dart" -ForegroundColor Green
