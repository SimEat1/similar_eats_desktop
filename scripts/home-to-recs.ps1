Write-Host "== Home: wire 'Find spots that match me' -> Recommendations ==" -ForegroundColor Cyan

$home = "lib/features/home/home_screen.dart"
if (!(Test-Path $home)) { Write-Host "  ! $home not found" -ForegroundColor Red; exit 1 }

$t = Get-Content -Raw $home

# Ensure import
$imp = "import 'package:similar_eats_desktop/features/recommendations/presentation/recommendations_screen.dart';"
if ($t -notmatch [regex]::Escape($imp)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $imp + "`r`n")
  } else { $t = $imp + "`r`n" + $t }
}

# Try to find the card/tile whose title is "Find spots that match me"
$block = "(?<w>(ListTile|InkWell|GestureDetector)\s*\((?:(?!\)).)*?title:\s*Text\(['""]Find spots that match me['""]\)(?:(?!\)).)*?\))"
if ($t -match $block) {
  $t = [regex]::Replace($t, $block, {
    param($m)
    $w = $m.Groups['w'].Value
    if ($w -notmatch "onTap\s*:") {
      return ($w -replace "\)$", ", onTap: () => Navigator.of(context).pushNamed(RecommendationsScreen.route))")
    } else {
      return ($w -replace "onTap\s*:\s*[^,)]*", "onTap: () => Navigator.of(context).pushNamed(RecommendationsScreen.route)")
    }
  }, 1)
  Set-Content -Encoding UTF8 $home $t
  Write-Host "  ✓ Patched Home card to open Recommendations" -ForegroundColor Green
} else {
  Write-Host "  = Couldn't auto-find the card. Dropping a manual snippet." -ForegroundColor Yellow
  @"
/// Manual paste inside the 'Find spots that match me' widget:
onTap: () => Navigator.of(context).pushNamed(RecommendationsScreen.route),
"@ | Set-Content -Encoding UTF8 .\lib\features\recommendations\INTEGRATION_SNIPPETS_HOME_TO_RECS.txt
  Write-Host "  ✓ Wrote INTEGRATION_SNIPPETS_HOME_TO_RECS.txt" -ForegroundColor Green
}

