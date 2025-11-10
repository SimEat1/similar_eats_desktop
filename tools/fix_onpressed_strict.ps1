# tools/fix_onpressed_strict.ps1
# Requires PowerShell 7+

$ErrorActionPreference = 'Stop'
$quick = "lib/features/visits/screens/quick_visit_screen.dart"
if (!(Test-Path $quick)) { throw "Missing $quick" }

# Backup
$stamp = Get-Date -Format yyyyMMddHHmmss
Copy-Item $quick "$quick.bak-$stamp"
Write-Host "Backup => $quick.bak-$stamp"

# Read entire file
$text = Get-Content $quick -Raw

# Find first FilledButton(
$name     = 'FilledButton'
$start    = $text.IndexOf("$name(")
if ($start -lt 0) { throw "No FilledButton(...) found." }

$openIdx  = $text.IndexOf('(', $start + $name.Length)
if ($openIdx -lt 0) { throw "Could not find '(' after $name" }

# Walk to matching ')'
$depth = 1; $end = -1
for ($i = $openIdx + 1; $i -lt $text.Length; $i++) {
  $ch = $text[$i]
  if     ($ch -eq '(') { $depth++ }
  elseif ($ch -eq ')') { $depth--; if ($depth -eq 0) { $end = $i; break } }
}
if ($end -lt 0) { throw "Could not match closing ')' for $name call." }

$before = $text.Substring(0, $openIdx + 1)
$args   = $text.Substring($openIdx + 1, $end - $openIdx - 1)
$after  = $text.Substring($end)

# Helper: remove the FIRST onPressed: argument (properly handles nested parens)
function Remove-FirstOnPressed {
  param([string]$s)

  $needle = 'onPressed:'
  $idx = $s.IndexOf($needle)
  if ($idx -lt 0) { return $s } # nothing to remove

  $j = $idx + $needle.Length
  $depth = 0
  # consume whitespace
  while ($j -lt $s.Length -and [char]::IsWhiteSpace($s[$j])) { $j++ }

  # advance until we hit a top-level comma OR end, while tracking nested (...)
  while ($j -lt $s.Length) {
    $c = $s[$j]
    if ($c -eq '(') { $depth++ }
    elseif ($c -eq ')') { if ($depth -gt 0) { $depth-- } }
    elseif ($c -eq ',' -and $depth -eq 0) { break }
    $j++
  }

  # slice: everything before onPressed + (skip trailing comma if present) + everything after
  $afterIdx = $j
  if ($afterIdx -lt $s.Length -and $s[$afterIdx] -eq ',') { $afterIdx++ } # drop the comma too
  ($s.Substring(0, $idx) + $s.Substring($afterIdx)).Trim()
}

# 1) Remove any existing onPressed (just the first; if multiple, we loop)
$prev = $null
do {
  $prev = $args
  $args = Remove-FirstOnPressed $args
} while ($args -ne $prev)

# 2) Insert the clean onPressed at the BEGINNING (with trailing comma)
$clean = 'onPressed: _dirty ? _onSavePressed : null'
if ($args.Trim().Length -gt 0) {
  # ensure there is a comma after our insertion
  $args = "$clean, $args"
} else {
  $args = "$clean"
}

# 3) Normalize accidental doubles like ',,', ', ,'
$args = [regex]::Replace($args, '\s*,\s*,\s*', ', ')
# Also strip any leftover junk like '? _onSavePressed : null' that might have been
# outside the original onPressed span (extremely rare, but safe to clean):
$args = [regex]::Replace($args, '\s*\?\s*_onSavePressed\s*:\s*null', '')

# Reassemble
$text = $before + $args + $after
$text | Set-Content $quick -Encoding UTF8

# Format + analyze
dart format $quick | Out-Host
flutter analyze $quick | Out-Host

Write-Host "Done. Rewrote the first FilledButton.onPressed cleanly." -ForegroundColor Cyan

