Write-Host "== Wire Home card -> Recommendations ==" -ForegroundColor Cyan

$home = "lib/features/home/home_screen.dart"
if (!(Test-Path $home)) {
  Write-Host "  ! $home not found. If Home is elsewhere, tell me the path." -ForegroundColor Red
  exit 1
}

$t = Get-Content -Raw $home

# 1) Ensure import
$import = "import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';"
if ($t -notmatch [regex]::Escape($import)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $import + "`r`n")
  } else {
    $t = $import + "`r`n" + $t
  }
}

# 2) Best-effort: make the first “Find spots that match me” card navigate.
# Try to find a ListTile or InkWell with that title and inject onTap => pushNamed(RecommendationsScreen.route)
$pattern = "(ListTile|InkWell|GestureDetector)\s*\((?:(?!\)).)*?(title:\s*Text\(['""]Find spots that match me['""]\))(?:(?!\)).)*?\)"
if ($t -match $pattern) {
  $t = [regex]::Replace($t, $pattern, {
    param($m)
    $block = $m.Value
    if ($block -notmatch "onTap\s*:") {
      $block = $block -replace "\)$", ", onTap: () => Navigator.of(context).pushNamed(RecommendationsScreen.route))"
    } else {
      $block = $block -replace "onTap\s*:\s*[^,)]*", "onTap: () => Navigator.of(context).pushNamed(RecommendationsScreen.route)"
    }
    return $block
  }, 1)
  Set-Content -Encoding UTF8 $home $t
  Write-Host "  ✓ Patched $home (Home card opens Recommendations)" -ForegroundColor Green
} else {
  Write-Host "  = Couldn't auto-find the Home card. I'll drop a snippet for manual paste." -ForegroundColor Yellow
  @"
/// Manual snippet (put inside your Home card/widget)
onTap: () => Navigator.of(context).pushNamed(RecommendationsScreen.route),
"@ | Set-Content -Encoding UTF8 .\lib\features\recommendations\INTEGRATION_SNIPPETS_HOME_TO_RECS.txt
  Write-Host "  ✓ Wrote INTEGRATION_SNIPPETS_HOME_TO_RECS.txt" -ForegroundColor Green
}
