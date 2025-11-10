param([string]$File = "lib/bootstrap_providers.dart")

Write-Host "== Fix TasteQuizController provider constructor ==" -ForegroundColor Cyan

if (!(Test-Path $File)) { Write-Host "  ! $File not found" -ForegroundColor Red; exit 1 }

$t = Get-Content -Raw $File

# Figure out which repo exists and set import + constructor accordingly
$repoImport = $null
$repoCtor   = $null

$repoAPath = "lib/features/taste_profiles/repo/taste_profiles_repo.dart"
$repoBPath = "lib/features/profile/data/taste_profile_repository.dart"

if (Test-Path $repoAPath) {
  $repoImport = "import 'features/taste_profiles/repo/taste_profiles_repo.dart';"
  $repoCtor   = "TasteQuizController(TasteProfilesRepo())..init()"
  Write-Host "  ✓ Using TasteProfilesRepo" -ForegroundColor Green
} elseif (Test-Path $repoBPath) {
  $repoImport = "import 'features/profile/data/taste_profile_repository.dart';"
  $repoCtor   = "TasteQuizController(TasteProfileRepository())..init()"
  Write-Host "  ✓ Using TasteProfileRepository" -ForegroundColor Green
} else {
  Write-Host "  ! Could not find a taste profile repo file." -ForegroundColor Red
  Write-Host "    Expected one of:" -ForegroundColor Yellow
  Write-Host "      - $repoAPath" -ForegroundColor Yellow
  Write-Host "      - $repoBPath" -ForegroundColor Yellow
  exit 1
}

# Ensure controller import
$ctrlImport = "import 'features/taste_quiz/presentation/taste_quiz_controller.dart';"
if ($t -notmatch [regex]::Escape($ctrlImport)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $ctrlImport + "`r`n")
  } else { $t = $ctrlImport + "`r`n" + $t }
}

# Ensure repo import
if ($t -notmatch [regex]::Escape($repoImport)) {
  if ($t -match "^(import\s+['""][^;]+['""];\s*)+") {
    $t = $t -replace "^(import\s+['""][^;]+['""];\s*)+", ('$0' + $repoImport + "`r`n")
  } else { $t = $repoImport + "`r`n" + $t }
}

# Replace the provider line to pass the repo
# We’ll match any TasteQuizController(...) in the providers list and replace its constructor args
$pattern = "ChangeNotifierProvider\(create:\s*\(_\)\s*=>\s*TasteQuizController\([^\)]*\)\s*\.\.\s*init\(\)\s*\),"
if ($t -match $pattern) {
  $t = [regex]::Replace($t, $pattern, "ChangeNotifierProvider(create: (_) => $repoCtor),", 1)
} else {
  # If the empty-args version exists, fix it
  $pattern2 = "ChangeNotifierProvider\(create:\s*\(_\)\s*=>\s*TasteQuizController\(\)\s*\.\.\s*init\(\)\s*\),"
  if ($t -match $pattern2) {
    $t = [regex]::Replace($t, $pattern2, "ChangeNotifierProvider(create: (_) => $repoCtor),", 1)
  } else {
    # Insert into providers: [ ... ] if missing entirely
    $providerLine = "ChangeNotifierProvider(create: (_) => $repoCtor),"
    if ($t -match "providers\s*:\s*\[") {
      $t = [regex]::Replace($t, "providers\s*:\s*\[", ("providers: [" + $providerLine + " "), 1)
    } else {
      Write-Host "  ! Couldn't find a providers: [ ... ] block. Open $File and add:" -ForegroundColor Red
      Write-Host "      $providerLine" -ForegroundColor Yellow
      exit 1
    }
  }
}

Set-Content -Encoding UTF8 $File $t
Write-Host "  ✓ Updated $File" -ForegroundColor Green
Write-Host "`nNext:" -ForegroundColor Cyan
Write-Host "  1) flutter clean" -ForegroundColor Yellow
Write-Host "  2) flutter pub get" -ForegroundColor Yellow
Write-Host "  3) flutter run -d windows" -ForegroundColor Yellow
