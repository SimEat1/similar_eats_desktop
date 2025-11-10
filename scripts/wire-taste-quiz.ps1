param([string]$ProjectRoot = (Get-Location).Path)
Write-Host "== Similar Eats: Wiring Taste Quiz -> Profile + Result Screen ==" -ForegroundColor Cyan
Set-Location $ProjectRoot
flutter pub add shared_preferences provider | Out-Null

$dirs = @(
  "lib/features/taste_quiz",
  "lib/features/taste_quiz/data",
  "lib/features/taste_quiz/domain",
  "lib/features/taste_quiz/presentation",
  "test"
)
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }

# (same files you already created earlier; safe to overwrite)
# domain, store, controller, result screen, test…
# To keep this message short, we’ll just point to what you already have working.
# If you want me to paste the full bodies again here, say the word and I’ll drop them.
