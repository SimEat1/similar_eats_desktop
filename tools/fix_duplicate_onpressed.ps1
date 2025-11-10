# Requires PS 7+
$ErrorActionPreference = 'Stop'
$quick = "lib/features/visits/screens/quick_visit_screen.dart"
if (!(Test-Path $quick)) { throw "Missing $quick" }

# Backup
$stamp = Get-Date -Format yyyyMMddHHmmss
Copy-Item $quick "$quick.bak-$stamp"

# Load
$text = Get-Content $quick -Raw

# Find first FilledButton( ... )
$name = "FilledButton"
$start = $text.IndexOf("$name(")
if ($start -lt 0) { Write-Host "No FilledButton found. Nothing to do."; exit 0 }

# Walk to matching ')'
$openIdx = $text.IndexOf('(', $start + $name.Length)
$depth = 1; $end = -1
for ($i = $openIdx + 1; $i -lt $text.Length; $i++) {
  $ch = $text[$i]
  if ($ch -eq '(') { $depth++ }
  elseif ($ch -eq ')') { $depth--; if ($depth -eq 0) { $end = $i; break } }
}
if ($end -lt 0) { throw "Could not match closing ')' for first FilledButton call." }

$before = $text.Substring(0, $openIdx + 1)
$args   = $text.Substring($openIdx + 1, $end - $openIdx - 1)
$after  = $text.Substring($end)

# 1) Ensure first onPressed is _maybeSave
#    If there's already an onPressed, normalize it; otherwise inject at the start.
$hadOnPressed = $false
$args2 = [regex]::Replace(
  $args,
  'onPressed\s*:\s*(\(\)\s*async\s*\{[\s\S]*?\}|\(\)\s*=>\s*[^,}]+|_\w+)\s*,?',
  { $hadOnPressed = $true; 'onPressed: _maybeSave,' },
  'Singleline'
)
if (-not $hadOnPressed) {
  $args2 = ('onPressed: _maybeSave, ' + $args2).Trim()
}

# 2) Remove any **additional** onPressed after the first one inside this call
#    Do it by wiping all occurrences AFTER the very first `onPressed:` we just placed.
$firstIdx = $args2.IndexOf('onPressed:')
if ($firstIdx -ge 0) {
  $pre  = $args2.Substring(0, $firstIdx + 'onPressed: _maybeSave,'.Length)
  $post = $args2.Substring($firstIdx + 'onPressed: _maybeSave,'.Length)
  $post = [regex]::Replace($post, '\s*,?\s*onPressed\s*:\s*[^,)]*(?:\([^)]*\)[^,)]*)?', '', 'Singleline')
  $args2 = $pre + $post
}

$fixed = $before + $args2 + $after

# Save + format + quick analyze
$fixed | Set-Content $quick -Encoding UTF8
dart format $quick | Out-Host
flutter analyze $quick | Out-Host
Write-Host "Done. Duplicate onPressed removed." -ForegroundColor Cyan
