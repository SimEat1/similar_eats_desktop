Write-Host "== Wire Home -> Recommendations ==" -ForegroundColor Cyan

$home = "lib/features/home/home_screen.dart"
if (-not (Test-Path $home)) { Write-Host "  ! $home not found" -ForegroundColor Red; exit 1 }

$t = Get-Content -Raw $home

# Ensure import for Recommendations
$import = "import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';"
if ($t -notmatch [regex]::Escape($import)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
  } else { $t = $import + "`r`n" + $t }
}

# Replace the onTap for the first “Find spots that match me” tile to push Recommendations
# Looks for a callback body that currently navigates to explore/map and swaps it.
$t = [regex]::Replace(
  $t,
  "onTap:\s*\(\)\s*{\s*Navigator\.[^}]+}\s*,\s*\)\s*,\s*//\s*find\s*spots\s*tile",
  "onTap: () {
      Navigator.of(context).pushNamed(RecommendationsScreen.route);
    },), // find spots tile",
  1
)

# Fallback: if we didn’t catch a comment anchor, do a broader replace of the first onTap in the “find spots” card
if ($t -notmatch "RecommendationsScreen\.route") {
  $t = [regex]::Replace(
    $t,
    "(Find spots that match me[\s\S]{0,400}?onTap:\s*\(\)\s*{)[\s\S]{0,200}?}",
    "`$1
      Navigator.of(context).pushNamed(RecommendationsScreen.route);
    }",
    1
  )
}

Set-Content -Encoding UTF8 $home $t
Write-Host "  ✓ Patched $home" -ForegroundColor Green
