Write-Host "== Similar Eats: fixing PlatformHelper imports ==" -ForegroundColor Cyan

$pkg = "similar_eats_desktop"
$good = "import 'package:$pkg/core/platform/platform_helper.dart';"

# Regex matches any import like: import 'core/platform/platform_helper.dart';
# or with any number of ../ prefixes.
$badRe = "import\s+['""](?:\.{0,2}/)*core/platform/platform_helper\.dart['""];"

$changed = @()
Get-ChildItem -Path .\lib -Recurse -Include *.dart | ForEach-Object {
  $p = $_.FullName
  $t = Get-Content -Raw -Path $p

  $hadBad = $false
  if ($t -match $badRe) {
    $t = [regex]::Replace($t, $badRe, $good)
    $hadBad = $true
  }

  # If both bad and good exist after replacement (duplicate), drop duplicates.
  # Remove any duplicate lines of the good import, keep only the first.
  if ($t -match [regex]::Escape($good)) {
    $lines = $t -split "(\r?\n)"
    $seen = $false
    for ($i = 0; $i -lt $lines.Length; $i++) {
      if ($lines[$i] -eq $good) {
        if ($seen) { $lines[$i] = "" } else { $seen = $true }
      }
    }
    $t = ($lines -join "")
  }

  if ($hadBad) {
    Set-Content -Encoding UTF8 -Path $p -Value $t
    $changed += $p
    Write-Host "  ✓ fixed: $p" -ForegroundColor Green
  }
}

if ($changed.Count -eq 0) {
  Write-Host "  = No bad imports found." -ForegroundColor DarkGray
} else {
  Write-Host "`n  ✓ Updated $($changed.Count) file(s)." -ForegroundColor Green
}
