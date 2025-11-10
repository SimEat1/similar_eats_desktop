param([string]$Controller = "lib/features/taste_quiz/presentation/taste_quiz_controller.dart")

Write-Host "== Repair TasteQuizController: optional constructor using _store ==" -ForegroundColor Cyan
if (!(Test-Path $Controller)) { Write-Host "  ! $Controller not found" -ForegroundColor Red; exit 1 }

$src  = Get-Content -Raw $Controller
$orig = $src

# 1) Ensure we have a private _store field and make it dynamic/nullable
$hadStoreField = $false
if ($src -match "final\s+[A-Za-z0-9_<>?\s]+\s+_store\s*;") {
  $src = [regex]::Replace($src, "final\s+[A-Za-z0-9_<>?\s]+\s+_store\s*;", "final dynamic _store;", 1)
  $hadStoreField = $true
} else {
  # Insert a field after the class declaration line
  $src = [regex]::Replace($src, "(class\s+TasteQuizController[^{]*\{)", "`$1`r`n  final dynamic _store;", 1)
}

# 2) Normalize the constructor to: TasteQuizController([dynamic store]) : _store = store { ... 
# This replaces whatever constructor signature exists up to the opening '{'
$src = [regex]::Replace(
  $src,
  "TasteQuizController\s*\([^\)]*\)\s*(?::[^{]*)?\{",
  "TasteQuizController([dynamic store]) : _store = store {",
  1
)

if ($src -ne $orig) {
  Copy-Item $Controller "$Controller.bak" -Force
  Set-Content -Encoding UTF8 $Controller $src
  Write-Host "  ✓ Patched $Controller (field + constructor)" -ForegroundColor Green
} else {
  Write-Host "  = No changes detected (file may already be in the desired state)" -ForegroundColor DarkGray
}

Write-Host "`nNext:" -ForegroundColor Cyan
Write-Host "  1) flutter clean" -ForegroundColor Yellow
Write-Host "  2) flutter pub get" -ForegroundColor Yellow
Write-Host "  3) flutter run -d windows" -ForegroundColor Yellow
