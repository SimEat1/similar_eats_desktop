New-Item -ItemType Directory -Force -Path .\scripts | Out-Null

@'
Write-Host "== Wire up Recommendations entry ==" -ForegroundColor Cyan

function Add-ImportIfMissing([string]$file, [string]$import) {
  if (-not (Test-Path $file)) { return }
  $t = Get-Content -Raw $file
  if ($t -notmatch [regex]::Escape($import)) {
    if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
      $t = [regex]::Replace($t, "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n"))
    } else {
      $t = $import + "`r`n" + $t
    }
    Set-Content -Encoding UTF8 $file $t
    Write-Host "  + import added -> $file" -ForegroundColor Green
  }
}

function EnsureRoute([string]$file) {
  if (-not (Test-Path $file)) { return }
  $t = Get-Content -Raw $file
  $import = "import 'features/recommendations/presentation/recommendations_screen.dart';"
  if ($t -notmatch [regex]::Escape($import)) {
    if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
      $t = [regex]::Replace($t, "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n"))
    } else {
      $t = $import + "`r`n" + $t
    }
  }

  $routeEntry = "RecommendationsScreen.route: (_) => const RecommendationsScreen(),"

  if ($t -match "MaterialApp\s*\(") {
    if ($t -match "routes\s*:\s*{") {
      # insert right after the first "routes: {"
      $t = [regex]::Replace($t, "routes\s*:\s*{", "routes: { $routeEntry ", 1)
    } else {
      # prepend routes into MaterialApp(
      $t = [regex]::Replace($t, "MaterialApp\s*\(", "MaterialApp(" + "routes: { $routeEntry }, ", 1)
    }
  }

  Set-Content -Encoding UTF8 $file $t
  Write-Host "  ✓ route ensured -> $file" -ForegroundColor Green
}

function PatchExploreMap([string]$file) {
  if (-not (Test-Path $file)) { Write-Host "  ! $file not found" -ForegroundColor Red; return }
  $t = Get-Content -Raw $file

  # Import for screen
  $imp = "import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';"
  if ($t -notmatch [regex]::Escape($imp)) {
    if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
      $t = [regex]::Replace($t, "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $imp + "`r`n"))
    } else {
      $t = $imp + "`r`n" + $t
    }
  }

  # Add a heart action to AppBar – simplest & robust: inject actions param right after AppBar(
  $actionsOneLine = "actions: [ IconButton(tooltip: 'Show matches list', icon: Icon(Icons.favorite), onPressed: () { Navigator.of(context).pushNamed(RecommendationsScreen.route); },), ], "

  if ($t -match "appBar\s*:\s*AppBar\s*\(") {
    if ($t -notmatch "actions\s*:") {
      $t = [regex]::Replace($t, "appBar\s*:\s*AppBar\s*\(", "appBar: AppBar(" + $actionsOneLine, 1)
      Write-Host "  ✓ added AppBar heart action -> $file" -ForegroundColor Green
    } else {
      Write-Host "  = AppBar already has actions; skipping" -ForegroundColor DarkGray
    }
  } else {
    Write-Host "  ! Could not find 'appBar: AppBar(' in $file (no change)" -ForegroundColor Yellow
  }

  Set-Content -Encoding UTF8 $file $t
}

# ---- Run patches ----
$mainFiles = @("lib\main.dart","lib\main_demo.dart") | Where-Object { Test-Path $_ }
foreach ($mf in $mainFiles) { EnsureRoute $mf }

PatchExploreMap "lib\features\explore\explore_map_screen.dart"

Write-Host "`nDone. Rebuild and tap the heart on the map to see Recommendations." -ForegroundColor Cyan
'@ | Set-Content -Encoding UTF8 .\scripts\wire-recs.ps1
