Write-Host "== Undo desktop guards inserted in taste profile files ==" -ForegroundColor Cyan

$targets = @(
  "lib/features/profile/data/taste_profile_repository.dart",
  "lib/features/taste_profiles/repo/taste_profiles_repo.dart",
  "lib/features/taste_quiz/presentation/taste_quiz_screen.dart",
  "lib/features/quiz/taste_quiz_screen.dart"
) | Where-Object { Test-Path $_ }

if ($targets.Count -eq 0) {
  Write-Host "  = No candidate files found, nothing to clean." -ForegroundColor DarkGray
  exit 0
}

# Patterns we inserted earlier
$saveGuard = "(?s)\s*// Desktop: save taste profile locally instead of Firestore.*?return;\s*\}\s*"
$loadGuard = "(?s)\s*// Desktop: load taste profile locally.*?\}\s*"

foreach ($f in $targets) {
  $t = Get-Content -Raw $f
  $orig = $t
  $t = [regex]::Replace($t, $saveGuard, "")
  $t = [regex]::Replace($t, $loadGuard, "")
  if ($t -ne $orig) {
    Set-Content -Encoding UTF8 $f $t
    Write-Host "  ✓ cleaned $f" -ForegroundColor Green
  } else {
    Write-Host "  = no injected blocks in $f" -ForegroundColor DarkGray
  }
}

Write-Host "`nDone. Try building again." -ForegroundColor Cyan
