param(
  [string]$Root = (Get-Location).Path
)

Write-Host "== Replace 'desktop-mock' string literals with current FirebaseAuth uid ==" -ForegroundColor Cyan
Set-Location $Root

$dartFiles = Get-ChildItem -Recurse -Path "$Root\lib" -Filter *.dart | Select-Object -ExpandProperty FullName

# Find files containing 'desktop-mock'
$hits = Select-String -Path $dartFiles -Pattern 'desktop-mock' -SimpleMatch
if (-not $hits) {
  Write-Host "  = No occurrences found (nothing to do)" -ForegroundColor DarkGray
  exit 0
}

$files = $hits | Select-Object -ExpandProperty Path -Unique
Write-Host "  • Will patch:" -ForegroundColor Yellow
$files | ForEach-Object { Write-Host "    - $_" }

# Replace 'desktop-mock' OR "desktop-mock" with the UID expression
$pattern = "'desktop-mock'|`"desktop-mock`""
$replacement = "(FirebaseAuth.instance.currentUser?.uid ?? 'desktop-mock')"

foreach ($f in $files) {
  $txt = Get-Content -Raw $f
  $new = [regex]::Replace($txt, $pattern, $replacement)
  if ($new -ne $txt) {
    Copy-Item $f "$f.bak" -Force
    Set-Content -Encoding UTF8 $f $new
    Write-Host "  ✓ Patched $f" -ForegroundColor Green
  } else {
    Write-Host "  = No changes in $f" -ForegroundColor DarkGray
  }
}

Write-Host "`nNext:" -ForegroundColor Cyan
Write-Host "  flutter clean" -ForegroundColor Yellow
Write-Host "  flutter pub get" -ForegroundColor Yellow
Write-Host "  flutter run -d windows" -ForegroundColor Yellow
