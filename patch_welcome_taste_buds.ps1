# patch_welcome_taste_buds.ps1
# Adds a people-icon action to WelcomeScreen AppBar to open /taste_buds
$ErrorActionPreference = "Stop"

$path = "lib\features\home\welcome_screen.dart"
if (-not (Test-Path $path)) { throw "Cannot find $path" }
$src = Get-Content -Raw $path

# --- ensure import ---
if ($src -notmatch "taste_buds_screen.dart") {
  $src = $src -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:similar_eats_desktop/features/buds/screens/taste_buds_screen.dart';`r`n"
  Write-Host "Added import."
}

# --- add AppBar action ---
if ($src -match "appBar:\s*AppBar\(" -and $src -notmatch "Icons\.group_outlined") {
  $src = $src -replace
    "appBar:\s*AppBar\(([^)]*)\)",
    "appBar: AppBar(`$1, actions:[IconButton(tooltip:'Taste Buds',icon:Icon(Icons.group_outlined),onPressed:()=>Navigator.pushNamed(context,'/taste_buds'),)],)"
  Write-Host "Added Taste Buds icon to AppBar."
} else {
  Write-Host "AppBar already patched or pattern not found."
}

Copy-Item $path "$path.bak" -Force
Set-Content -Path $path -Value $src -Encoding UTF8 -NoNewline
Write-Host "Patched $path (backup at $path.bak)."
