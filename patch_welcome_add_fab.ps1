# patch_welcome_add_fab.ps1
# Cleans up AppBar actions on WelcomeScreen and adds a floating Taste Buds button.

$ErrorActionPreference = "Stop"

$path = "lib\features\home\welcome_screen.dart"
if (-not (Test-Path $path)) { throw "Cannot find $path" }

$src = Get-Content -Raw $path

# 0) Ensure import for Taste Buds screen
if ($src -notmatch "features/buds/screens/taste_buds_screen.dart") {
  $src = $src -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:similar_eats_desktop/features/buds/screens/taste_buds_screen.dart';`r`n"
  Write-Host "Added Taste Buds import."
}

# 1) Remove any AppBar actions we previously injected (be gentle).
#    This targets patterns like: actions: [ ... ],
$src = $src -replace "(?s)actions\s*:\s*\[.*?\]\s*,", ""
# Also fix stray double-commas if any
$src = $src -replace ",\s*,", ", "

# 2) Add a floatingActionButton to the first Scaffold(...) if not present.
if ($src -notmatch "floatingActionButton\s*:") {
  # Insert right after 'Scaffold('
  $fab = "floatingActionButton: FloatingActionButton(tooltip: 'Taste Buds', child: const Icon(Icons.group_outlined), onPressed: () => Navigator.pushNamed(context, '/taste_buds')), "
  $src = $src -replace "Scaffold\s*\(", "Scaffold($fab"
  Write-Host "Added FloatingActionButton to WelcomeScreen Scaffold."
} else {
  Write-Host "Found existing floatingActionButton; not adding another."
}

# 3) Write backup and save
Copy-Item $path "$path.bak" -Force
Set-Content -Path $path -Value $src -Encoding UTF8 -NoNewline
Write-Host "Patched $path (backup at $path.bak)."
