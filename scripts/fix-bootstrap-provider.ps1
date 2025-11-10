param([string]$Bootstrap = "lib/bootstrap_providers.dart")
Write-Host "== Ensure TasteQuizController()..init() in MultiProvider ==" -ForegroundColor Cyan
if (!(Test-Path $Bootstrap)) { Write-Host "  ! $Bootstrap not found" -ForegroundColor Red; exit 1 }
$t = Get-Content -Raw $Bootstrap

# import (idempotent)
$imp = "import 'features/taste_quiz/presentation/taste_quiz_controller.dart';"
if ($t -notmatch [regex]::Escape($imp)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $imp + "`r`n")
  } else { $t = $imp + "`r`n" + $t }
}

# replace any TasteQuizController(...) in providers with no-arg form
$t = [regex]::Replace(
  $t,
  "ChangeNotifierProvider\(create:\s*\(_\)\s*=>\s*TasteQuizController\([^\)]*\)\s*\.\.\s*init\(\)\s*\),",
  "ChangeNotifierProvider(create: (_) => TasteQuizController()..init()),"
)
# if missing entirely, try to inject at start of providers: [
if ($t -notmatch "TasteQuizController\(\)\.\.init\(\)") {
  if ($t -match "providers\s*:\s*\[") {
    $t = [regex]::Replace($t, "providers\s*:\s*\[", "providers: [ ChangeNotifierProvider(create: (_) => TasteQuizController()..init()), ", 1)
  }
}

Set-Content -Encoding UTF8 $Bootstrap $t
Write-Host "  ✓ Patched $Bootstrap" -ForegroundColor Green
