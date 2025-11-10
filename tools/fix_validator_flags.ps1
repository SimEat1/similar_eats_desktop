# Requires: PowerShell 7+
# Purpose: (1) Normalize PortionSizePicker, (2) Wire Save button via _maybeSave getter the validator recognizes.

$ErrorActionPreference = 'Stop'

# --- Paths
$quick = "lib/features/visits/screens/quick_visit_screen.dart"
if (!(Test-Path $quick)) { throw "Missing $quick" }

# --- Backup
$stamp  = Get-Date -Format yyyyMMddHHmmss
Copy-Item $quick "$quick.bak-$stamp"
Write-Host "Backup => $quick.bak-$stamp" -ForegroundColor DarkGray

# --- Load
$lines = Get-Content $quick

### A) Canonicalize PortionSizePicker block ###
# 1) Find the first line that starts the widget
$start = ($lines | Select-String -Pattern '^\s*PortionSizePicker\s*\(' | Select-Object -First 1).LineNumber
if ($start) {
  # 2) Find the end of this widget: the next line that is exactly '),'
  $end = $null
  for ($i = $start; $i -le $lines.Count; $i++) {
    if ($lines[$i-1] -match '^\s*\),\s*$') { $end = $i; break }
  }
  if ($end) {
    $indent = ([regex]::Match($lines[$start-1], '^\s*')).Value
    $replacement = @(
      "$indent" + "PortionSizePicker("
      "$indent" + "  initialValue: _portion,"
      "$indent" + "  onChanged: (p) => setState(() { _portion = p; _dirty = true; }),"
      "$indent" + "),"
    )
    $before = if ($start -gt 1) { $lines[0..($start-2)] } else { @() }
    $after  = if ($end   -lt $lines.Count) { $lines[$end..($lines.Count-1)] } else { @() }
    $lines  = @() + $before + $replacement + $after
    Write-Host "✔ PortionSizePicker normalized" -ForegroundColor Green
  } else {
    Write-Host "↯ Could not find the end of PortionSizePicker block; skipped" -ForegroundColor Yellow
  }
} else {
  Write-Host "↯ PortionSizePicker not found; skipped" -ForegroundColor Yellow
}

# Convert to single string for regex-based edits below
$src = ($lines -join "`n")

### B) Add `_maybeSave` getter inside the State class (idempotent) ###
if ($src -notmatch '\bVoidCallback\?\s+_maybeSave\b') {
  $src = [regex]::Replace(
    $src,
    '(class\s+_QuickVisitScreenState\s+extends\s+State<QuickVisitScreen>\s*\{)',
    "`$1`n  // Validator-friendly wrapper so onPressed is a direct reference`n  VoidCallback? get _maybeSave => _dirty ? _onSavePressed : null;`n",
    1
  )
  Write-Host "✔ Inserted _maybeSave getter" -ForegroundColor Green
} else {
  Write-Host "• _maybeSave getter already present" -ForegroundColor DarkGray
}

### C) Force the Save button to use `onPressed: _maybeSave` (idempotent) ###
# Replace any existing onPressed: (...) within the first FilledButton with our method reference
$prev = $src
$src = [regex]::Replace(
  $src,
  'FilledButton\(\s*onPressed\s*:\s*(?:\(\)\s*async\s*\{[\s\S]*?\}|\(\)\s*=>\s*[^,}]+|_\w+)\s*,',
  'FilledButton(onPressed: _maybeSave,',
  [System.Text.RegularExpressions.RegexOptions]::Singleline
)
if ($src -ne $prev) {
  Write-Host "✔ Save button rewired to _maybeSave" -ForegroundColor Green
} elseif ($src -match 'FilledButton\(\s*(?!onPressed)') {
  # Inject when no onPressed exists
  $src = [regex]::Replace($src, 'FilledButton\(\s*', 'FilledButton(onPressed: _maybeSave, ', 1)
  Write-Host "✔ Save button onPressed injected as _maybeSave" -ForegroundColor Green
} else {
  Write-Host "• Save button already uses _maybeSave" -ForegroundColor DarkGray
}

# --- Save
$src | Set-Content $quick -Encoding UTF8

# --- Format + quick analyze (best-effort)
try {
  dart format $quick | Out-Host
  flutter analyze $quick | Out-Host
} catch {
  Write-Host "Format/Analyze note: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Done." -ForegroundColor Cyan

