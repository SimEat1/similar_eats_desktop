$ErrorActionPreference='Stop'

# Write helper
function Write-File($path, $content) {
  New-Item -ItemType Directory -Force -Path (Split-Path $path) | Out-Null
  Set-Content -Path $path -Value $content -Encoding UTF8
  Write-Host "Wrote $path"
}

# main_demo.dart
$mainDemo = @'
<<<MAIN_DEMO_DART>>>
'@
# anon_sign_in_screen.dart
$anon = @'
<<<ANON_SIGN_IN_DART>>>
'@
# taste_quiz_screen.dart
$quiz = @'
<<<TASTE_QUIZ_DART>>>
'@
# recent_visits_screen.dart
$recent = @'
<<<RECENT_VISITS_DART>>>
'@

$root = Resolve-Path .
Write-File "lib/main_demo.dart" ($mainDemo -replace '<<<MAIN_DEMO_DART>>>', @"
$(Get-Content -Raw -Path "lib/main_demo.dart" -ErrorAction SilentlyContinue)
"@).Trim()

Write-File "lib/features/auth/anon_sign_in_screen.dart" $anon
Write-File "lib/features/quiz/taste_quiz_screen.dart" $quiz
Write-File "lib/features/visits/screens/recent_visits_screen.dart" $recent

try { dart format lib | Out-Host } catch {}
Write-Host "`nNext: flutter run -d windows -t lib/main_demo.dart"



