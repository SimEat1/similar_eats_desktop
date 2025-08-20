# Applies a mobile-friendly theme in lib/main.dart if MaterialApp is present.
$ErrorActionPreference = "Stop"
$main = Join-Path $PSScriptRoot "..\lib\main.dart" | Resolve-Path
$text = Get-Content $main -Raw

if ($text -notmatch "MaterialApp") { 
  Write-Host "[=] No MaterialApp found; skipping theme tweak."
  exit 0
}

# Light-touch: ensure Material 3 + seed color; don’t try to rewrite your whole tree
$text = $text -replace "useMaterial3\s*:\s*false","useMaterial3: true"
if ($text -notmatch "useMaterial3") {
  $text = $text -replace "ThemeData\(","ThemeData(useMaterial3: true, "
}

if ($text -notmatch "ColorScheme\.fromSeed") {
  $text = $text -replace "ThemeData\(","ThemeData(colorScheme: ColorScheme.fromSeed\(seedColor: Colors.deepOrange\), "
}

Set-Content -Path $main -Value $text -Encoding UTF8
Write-Host "[OK] Mobile look applied."

