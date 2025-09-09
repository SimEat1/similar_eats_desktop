param(
  [Parameter(Mandatory=$true)][string]$name,            # e.g. quick_eats
  [string]$title = $null,                               # e.g. Quick Eats
  [string]$description = "Feature module.",
  [string]$rtdbPath = "",                               # e.g. /restaurants
  [string]$firestorePath = ""                           # e.g. users/{uid}/tasteProfile
)

# Normalize inputs
$proj = "C:\projects\similar_eats_desktop"
$featRoot = Join-Path $proj "lib\features"
$slug = ($name -replace '\s+', '_').ToLower()

# Title (Title Case)
if ($title) {
  $Title = $title
} else {
  $Title = ($slug -replace '_',' ')
  $Title = ($Title -split ' ') | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) } | Join-String ' '
}
$TitleNoSpace = ($Title -replace '\s','')

$root = Join-Path $featRoot $slug
$dirs = @("$root\models", "$root\repo", "$root\widgets", "$root\screens")

# Ensure dirs
foreach ($d in $dirs) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null } }

# Build the "Data" section lines safely (no $() inside here-strings)
$dataLines = @()
if ($rtdbPath)      { $dataLines += "Realtime Database: `$rtdbPath" }
if ($firestorePath) { $dataLines += "Firestore: `$firestorePath" }
$dataSection = if ($dataLines.Count) { ($dataLines -join "`n") } else { "" }

# README content
$readme = @"
# $Title

**Purpose:** $description

## Modules
- `models/` → data models
- `repo/` → data access, services
- `widgets/` → reusable UI
- `screens/` → screens / tabs

## Data
$dataSection

## Notes
- Add unit tests in `test/${slug}_test.dart` as the module grows.
- Keep public APIs small and documented in this README.
"@

# Write README
$readmePath = Join-Path $root "README.md"
Set-Content -Path $readmePath -Value $readme -Encoding UTF8

# Minimal, non-breaking stubs
$stubModel = @"
class ${TitleNoSpace}Model {
  const ${TitleNoSpace}Model();
}
"@
$stubRepo = @"
class ${TitleNoSpace}Repo {
  const ${TitleNoSpace}Repo();
}
"@
$stubWidget = @"
import 'package:flutter/widgets.dart';

class ${TitleNoSpace}Placeholder extends StatelessWidget {
  const ${TitleNoSpace}Placeholder({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
"@
$stubScreen = @"
import 'package:flutter/material.dart';

class ${TitleNoSpace}Screen extends StatelessWidget {
  const ${TitleNoSpace}Screen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('$Title')));
}
"@

Set-Content (Join-Path $root "models\placeholder.dart")  $stubModel  -Encoding UTF8
Set-Content (Join-Path $root "repo\placeholder.dart")    $stubRepo   -Encoding UTF8
Set-Content (Join-Path $root "widgets\placeholder.dart") $stubWidget -Encoding UTF8
Set-Content (Join-Path $root "screens\placeholder.dart") $stubScreen -Encoding UTF8

Write-Host "✅ Created feature module:" -ForegroundColor Green
Write-Host " - $root"
Write-Host " - $readmePath"
