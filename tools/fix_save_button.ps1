# Requires PowerShell 7+
$ErrorActionPreference = 'Stop'

$quick = "lib/features/visits/screens/quick_visit_screen.dart"
if (!(Test-Path $quick)) { throw "Missing $quick" }

# --- Backup
$stamp = Get-Date -Format yyyyMMddHHmmss
Copy-Item $quick "$quick.bak-$stamp"
Write-Host "Backup => $quick.bak-$stamp"

# --- Load
$text = Get-Content $quick -Raw

# 1) Remove ALL _maybeSave getters (single-line or multi-line to the first ';')
#    Handles:
#    - `VoidCallback? get _maybeSave => ...;`
#    - `get _maybeSave => ...;`
$text = [regex]::Replace(
  $text,
  '(?m)^\s*(?:\w+\??\s+)?get\s+_maybeSave\s*=>[\s\S]*?;\s*\r?\n?',
  '',
  'Singleline'
)

# 2) Fix the first FilledButton(...) so onPressed is exactly `_dirty ? _onSavePressed : null`
#    We locate the first FilledButton, rewrite its arg list, and
#    ensure only one onPressed remains.
$name = 'FilledButton'
$start = $text.IndexOf("$name(")
if ($start -ge 0) {
  $openIdx = $text.IndexOf('(', $start + $name.Length)
  if ($openIdx -lt 0) { throw "Could not find '(' after $name" }

  # Walk to matching ')'
  $depth = 1; $end = -1
  for ($i = $openIdx + 1; $i -lt $text.Length; $i++) {
    $ch = $text[$i]
    if ($ch -eq '(') { $depth++ }
    elseif ($ch -eq ')') { $depth--; if ($depth -eq 0) { $end = $i; break } }
  }
  if ($end -lt 0) { throw "Could not match closing ')' for first $name call." }

  $before = $text.Substring(0, $openIdx + 1)
  $args   = $text.Substring($openIdx + 1, $end - $openIdx - 1)
  $after  = $text.Substring($end)

  # (a) Force an onPressed at the very start
  $args2 = "onPressed: _dirty ? _onSavePressed : null, " + $args

  # (b) Remove any additional onPressed occurrences afterwards
  $firstIdx = $args2.IndexOf('onPressed:')
  if ($firstIdx -ge 0) {
    $pre  = $args2.Substring(0, $firstIdx + 'onPressed: _dirty ? _onSavePressed : null,'.Length)
    $post = $args2.Substring($firstIdx + 'onPressed: _dirty ? _onSavePressed : null,'.Length)
    $post = [regex]::Replace($post, '\s*,?\s*onPressed\s*:\s*[^,)]*(?:\([^)]*\)[^,)]*)?', '', 'Singleline')
    $args2 = $pre + $post
  }

  $text = $before + $args2 + $after
} else {
  Write-Host "No FilledButton found; skipping onPressed fix."
}

# --- Save + format + analyze
$text | Set-Content $quick -Encoding UTF8
dart format $quick | Out-Host
flutter analyze $quick | Out-Host

Write-Host "Done. Cleaned _maybeSave and normalized FilledButton.onPressed." -ForegroundColor Cyan
