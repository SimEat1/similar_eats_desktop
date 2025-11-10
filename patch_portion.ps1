<#  patch_portion.ps1
    - Adds enum helpers (lib/models/portion.dart)
    - Ensures import in quick_visit_screen.dart
    - Rewrites payload/save to use 'portion_size' string (XS/S/M/L/XL)
    - Leaves a timestamped .bak alongside any edited file
#>

[CmdletBinding()]
param(
  [string]$QuickFile = "lib/features/visits/screens/quick_visit_screen.dart",
  [string]$PortionFile = "lib/models/portion.dart",
  [string]$VisitModel = "lib/features/visits/models/visit.dart" # change if your model lives elsewhere
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Backup([string]$path) {
  if (-not (Test-Path $path)) { throw "File not found: $path" }
  $stamp = Get-Date -Format yyyyMMddHHmmss
  $bak = "$path.bak-$stamp"
  Copy-Item $path $bak -Force
  Write-Host "Backup => $bak"
}

function Ensure-FileDir([string]$path) {
  $dir = Split-Path $path -Parent
  if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
}

# 1) Ensure portion enum + helpers exist
if (-not (Test-Path $PortionFile)) {
  Ensure-FileDir $PortionFile
  @"
enum Portion { xs, s, m, l, xl }

extension PortionX on Portion {
  String get wire => name.toUpperCase(); // "XS".."XL"

  static Portion? fromWire(String? s) {
    switch (s?.toUpperCase()) {
      case 'XS': return Portion.xs;
      case 'S':  return Portion.s;
      case 'M':  return Portion.m;
      case 'L':  return Portion.l;
      case 'XL': return Portion.xl;
      default:   return null;
    }
  }
}
"@ | Set-Content -Encoding UTF8 $PortionFile
  Write-Host "Created $PortionFile"
} else {
  Write-Host "Found $PortionFile (skipping create)"
}

# 2) Patch the Quick Visit screen
Backup $QuickFile
$src = Get-Content $QuickFile -Raw

# 2a) Ensure import of portion.dart (skip if already imported)
$portionImport = "import 'package:similar_eats_desktop/models/portion.dart';"
if ($src -notmatch [regex]::Escape($portionImport)) {
  # Insert after last import; otherwise at top
  $m = [regex]::Matches($src, '^\s*import\s+.+?;\s*$', 'Multiline') | Select-Object -Last 1
  if ($m) {
    $idx = $m.Index + $m.Length
    $src = $src.Insert($idx, "`r`n$portionImport")
  } else {
    $src = "$portionImport`r`n$src"
  }
  Write-Host "Added import for portion.dart"
}

# 2b) Make common replacements in payload building (old nested 'portion' -> 'portion_size')
# Replace: 'portion': { 'size': something }
$src = [regex]::Replace($src,
  "'portion'\s*:\s*\{\s*'size'\s*:\s*[^}]+\}", "'portion_size': _portion?.wire")

$src = [regex]::Replace($src,
  '"portion"\s*:\s*\{\s*"size"\s*:\s*[^}]+\}', '"portion_size": _portion?.wire')

# Also convert any lingering _portion?.toString() used for size → .wire
$src = $src -replace [regex]::Escape('_portion?.toString()'), '_portion?.wire'

# 2c) In _saveVisit, ensure we pass portion_size straight through from payload
# Replace any mapping to a nested portion map with portion_size ref
$src = [regex]::Replace($src,
  '"portion"\s*:\s*\{\s*"size"\s*:\s*[^}]+\}\s*,?',
  '"portion_size": payload[''portion_size''],')

$src = [regex]::Replace($src,
  "'portion'\s*:\s*\{\s*'size'\s*:\s*[^}]+\}\s*,?",
  "'portion_size': payload[''portion_size''],")

# Remove any small sanitizing block that tried to convert "Portion(L)" → "L"
# (best-effort; leaves other code intact if pattern not present)
$src = [regex]::Replace($src,
  '(?s)String\?\s+portionSizeStr;.*?payload\["portion"\].*?\n\s*\}\s*\n',
  '')

# 2d) If your screen uses Portion? field, this is just a friendly hint line:
# (no-op if not found)
$src = $src -replace 'Portion\?\s+_portion\s*;', 'Portion? _portion;'

Set-Content $QuickFile -Encoding UTF8 -Value $src
Write-Host "Patched $QuickFile"

# 3) (Optional) Patch Visit model to carry portion_size
if (Test-Path $VisitModel) {
  Backup $VisitModel
  $vm = Get-Content $VisitModel -Raw
  # Try to add a nullable portionSize field if not present
  if ($vm -notmatch 'portionSize' -and $vm -match 'class\s+Visit\s*\{') {
    $vm = $vm -replace '(class\s+Visit\s*\{)', '$1' + "`n  final String? portionSize;"
    # constructor param
    $vm = $vm -replace '(Visit\(\{[^\)]*)\}', '$1, this.portionSize})'
    # toJson
    if ($vm -match 'Map<String,\s*dynamic>\s*toJson\(\)\s*\{') {
      $vm = $vm -replace '(\{[^}]*)(\}\s*$)', '$1' + "`n      'portion_size': portionSize,$2"
    }
    # fromJson
    if ($vm -match 'factory\s+Visit\.fromJson\(Map<String,\s*dynamic>\s*json\)\s*\{') {
      $vm = $vm -replace '(return\s+Visit\(\s*)([^\)]*)\)',
        "`$1`$2, portionSize: json['portion_size'] as String?)"
    }
    Set-Content $VisitModel -Encoding UTF8 -Value $vm
    Write-Host "Patched $VisitModel (added portionSize)"
  } else {
    Write-Host "Skipped $VisitModel (already defines portionSize or not a Visit class)"
  }
} else {
  Write-Host "Visit model not found at $VisitModel (skipping)"
}

# 4) Format + analyze (best-effort – no throw on non-zero)
try { dart format lib | Out-Host } catch {}
try { flutter analyze | Out-Host } catch {}

Write-Host "`nDone. Rebuild with:" -ForegroundColor Cyan
Write-Host "  flutter run -d windows -t lib/dev_quick_visit.dart"

