# patch_fonts_encoding.ps1
# - Forces Poppins via GoogleFonts across Material textTheme
# - Fixes smart quotes / odd chars in common UI strings
# - Re-saves with UTF8 (no BOM) to avoid artifacts

$ErrorActionPreference = "Stop"

function Save-Utf8($path, $text) {
  New-Item -ItemType File -Path $path -Force | Out-Null
  Set-Content -Path $path -Value $text -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# --- A) main.dart theme → Poppins ---
$mainPath = "lib\main.dart"
if (!(Test-Path $mainPath)) { throw "Missing $mainPath" }
$main = Get-Content -Raw $mainPath

if ($main -notmatch "package:google_fonts/google_fonts.dart") {
  $main = $main -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:google_fonts/google_fonts.dart';`r`n"
  Write-Host "Added google_fonts import to main.dart"
}

# Replace ThemeData(...) with a version that applies GoogleFonts.poppinsTextTheme
if ($main -match "ThemeData\s*\(" -and $main -notmatch "poppinsTextTheme") {
  $main = $main -replace "ThemeData\s*\(",
    "ThemeData(textTheme: GoogleFonts.poppinsTextTheme(),"
  Write-Host "Applied Poppins textTheme in ThemeData"
}

Copy-Item $mainPath "$mainPath.bak" -Force
Save-Utf8 $mainPath $main

# --- B) Clean welcome_screen.dart strings ---
$welcomePath = "lib\features\home\welcome_screen.dart"
if (Test-Path $welcomePath) {
  $txt = Get-Content -Raw $welcomePath

  # Normalize smart quotes / dashes
  $txt = $txt -replace "[\u2018\u2019]", "'"           # single quotes
  $txt = $txt -replace "[\u201C\u201D]", '"'           # double quotes
  $txt = $txt -replace "[\u2013\u2014]", "-"           # en/em dash

  # Ensure the hero line is clean ascii if it exists
  $txt = $txt -replace "Find your next.*?meal", "Find your next crave-worthy meal"

  Copy-Item $welcomePath "$welcomePath.bak" -Force
  Save-Utf8 $welcomePath $txt
  Write-Host "Normalized strings in welcome_screen.dart"
} else {
  Write-Host "welcome_screen.dart not found — skip normalization."
}

Write-Host "`nDone. Run: flutter pub get && flutter run -d windows"



