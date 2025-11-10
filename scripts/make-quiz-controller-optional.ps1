param(
  [string]$Controller = "lib/features/taste_quiz/presentation/taste_quiz_controller.dart",
  [string]$Bootstrap  = "lib/bootstrap_providers.dart"
)

Write-Host "== Make TasteQuizController accept optional store & fix provider ==" -ForegroundColor Cyan

# --- 1) Patch the controller to accept optional/dynamic store ---
if (!(Test-Path $Controller)) {
  Write-Host "  ! $Controller not found" -ForegroundColor Red
  exit 1
}

$src = Get-Content -Raw $Controller
$orig = $src

# a) Loosen the field type
$src = [regex]::Replace($src, "final\s+TasteProfileStore\s+(\w+)\s*;", "final dynamic `$1;")

# b) Make the constructor optional-arg. This covers common patterns:
#    - TasteQuizController(this.store);
#    - TasteQuizController(TasteProfileStore store);
#    - TasteQuizController({required this.store});
#    - TasteQuizController({required TasteProfileStore store});
$src = [regex]::Replace($src,
  "TasteQuizController\s*\([^\)]*\)",
  "TasteQuizController([this.store])"
)

if ($src -ne $orig) {
  Copy-Item $Controller "$Controller.bak" -Force
  Set-Content -Encoding UTF8 $Controller $src
  Write-Host "  ✓ Patched $Controller (constructor & field)" -ForegroundColor Green
} else {
  Write-Host "  = No changes made to $Controller (patterns not found; may already be optional)" -ForegroundColor DarkGray
}

# --- 2) Fix the provider call to use no-arg constructor ---
if (!(Test-Path $Bootstrap)) {
  Write-Host "  ! $Bootstrap not found" -ForegroundColor Red
  exit 1
}

$bt = Get-Content -Raw $Bootstrap
$borig = $bt

# Ensure controller import present
$ctrlImport = "import 'features/taste_quiz/presentation/taste_quiz_controller.dart';"
if ($bt -notmatch [regex]::Escape($ctrlImport)) {
  if ($bt -match "^(import\s+['""][^;]+['""];\s*)+") {
    $bt = $bt -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $ctrlImport + "`r`n")
  } else { $bt = $ctrlImport + "`r`n" + $bt }
}

# Replace any TasteQuizController(...) inside the ChangeNotifierProvider with no-arg version
$bt = [regex]::Replace(
  $bt,
  "ChangeNotifierProvider\(create:\s*\(_\)\s*=>\s*TasteQuizController\([^\)]*\)\s*\.\.\s*init\(\)\s*\),",
  "ChangeNotifierProvider(create: (_) => TasteQuizController()..init()),"
)

if ($bt -ne $borig) {
  Copy-Item $Bootstrap "$Bootstrap.bak" -Force
  Set-Content -Encoding UTF8 $Bootstrap $bt
  Write-Host "  ✓ Updated $Bootstrap (provider -> no-arg controller)" -ForegroundColor Green
} else {
  Write-Host "  = Provider line already uses no-arg controller (or not found)" -ForegroundColor DarkGray
}

Write-Host "`nNext:" -ForegroundColor Cyan
Write-Host "  1) flutter clean" -ForegroundColor Yellow
Write-Host "  2) flutter pub get" -ForegroundColor Yellow
Write-Host "  3) flutter run -d windows" -ForegroundColor Yellow
