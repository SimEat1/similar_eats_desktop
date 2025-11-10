# patch_welcome_fix.ps1
# Safely fixes the AppBar issue on WelcomeScreen by removing "const" and inserting a Taste Buds button.

$ErrorActionPreference = "Stop"

$path = "lib\features\home\welcome_screen.dart"
if (-not (Test-Path $path)) {
  throw "Cannot find $path"
}

$src = Get-Content -Raw $path

# Remove const from AppBar to allow runtime expressions
$src = $src -replace "appBar:\s*const\s+AppBar\(", "appBar: AppBar("

# Ensure import
if ($src -notmatch "features/buds/screens/taste_buds_screen.dart") {
  $src = $src -replace "(?s)(^(\s*import\s+['""][^;]+;[^\n]*\n)+)",
    "`$1import 'package:similar_eats_desktop/features/buds/screens/taste_buds_screen.dart';`r`n"
  Write-Host "Added import for Taste Buds screen."
}

# Add the AppBar action (skip if already present)
if ($src -match "appBar:\s*AppBar" -and $src -notmatch "Icons\.group_outlined") {
  $src = $src -replace "appBar:\s*AppBar\(([^)]*)\)",
"appBar: AppBar($1,
  actions: [
    IconButton(
      tooltip: 'Taste Buds',
      icon: Icon(Icons.group_outlined),
      onPressed: () => Navigator.pushNamed(context, '/taste_buds'),
    ),
  ],
)"
  Write-Host "Added Taste Buds icon to AppBar."
} else {
  Write-Host "AppBar already patched or found custom logic."
}

# Backup and write file
Copy-Item $path "$path.bak" -Force
Set-Content -Path $path -Value $src -Encoding UTF8 -NoNewline
Write-Host "Patched $path successfully. Backup saved as $path.bak"
