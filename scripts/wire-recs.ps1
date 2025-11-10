Write-Host "== Wire Recommendations entry points ==" -ForegroundColor Cyan

# 1) Add Recommendations route to main files
$mainFiles = @("lib\main.dart","lib\main_demo.dart") | Where-Object { Test-Path $_ }
foreach ($mf in $mainFiles) {
  $t = Get-Content -Raw $mf
  $import = "import 'features/recommendations/presentation/recommendations_screen.dart';"
  if ($t -notmatch [regex]::Escape($import)) {
    if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
      $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
    } else { $t = $import + "`r`n" + $t }
  }
  $routesAdd = "RecommendationsScreen.route: (_) => const RecommendationsScreen(),"
  if ($t -match "MaterialApp\s*\(") {
    if ($t -match "routes\s*:\s*{") {
      $t = [regex]::Replace($t, "routes\s*:\s*{", "routes: { $routesAdd ", 1)
    } else {
      $t = [regex]::Replace($t, "MaterialApp\s*\(", "MaterialApp(" + "routes: { $routesAdd }, ", 1)
    }
  }
  Set-Content -Encoding UTF8 $mf $t
  Write-Host "  ✓ Patched $mf (routes)" -ForegroundColor Green
}

# 2) Add a heart action to the Explore map AppBar that opens Recommendations
$map = "lib\features\explore\explore_map_screen.dart"
if (-not (Test-Path $map)) { Write-Host "  ! $map not found" -ForegroundColor Red; exit 1 }

$t = Get-Content -Raw $map

# Ensure import
$imp = "import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';"
if ($t -notmatch [regex]::Escape($imp)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $imp + "`r`n")
  } else { $t = $imp + "`r`n" + $t }
}

$button = @"
IconButton(
  icon: const Icon(Icons.favorite),
  tooltip: 'My matches',
  onPressed: () => Navigator.of(context).pushNamed(RecommendationsScreen.route),
),
"@

if ($t -match "actions\s*:\s*\[") {
  # Prepend our button to existing actions list
  $t = [regex]::Replace($t, "actions\s*:\s*\[", ("actions: [" + $button), 1)
  Write-Host "  ✓ Added heart to existing AppBar actions" -ForegroundColor Green
} else {
  # Inject a new actions: [...] into the first AppBar(
  $inject = "AppBar(actions: [ $button ], "
  $t = [regex]::Replace($t, "AppBar\s*\(", $inject, 1)
  Write-Host "  ✓ Inserted actions into AppBar" -ForegroundColor Green
}

Set-Content -Encoding UTF8 $map $t
Write-Host "  ✓ Patched explore_map_screen.dart" -ForegroundColor Green

Write-Host "`nDone. Build & run, then tap the heart on the Explore map AppBar." -ForegroundColor Cyan
