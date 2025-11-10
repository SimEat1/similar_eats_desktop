# tools/fix_onpressed_simple.ps1
# PowerShell 7+  — fixes the FIRST FilledButton(...) onPressed to:
#   onPressed: _dirty ? _onSavePressed : null,

$ErrorActionPreference = 'Stop'
$quick = "lib/features/visits/screens/quick_visit_screen.dart"
if (!(Test-Path $quick)) { throw "Missing $quick" }

# Backup
$stamp = Get-Date -Format yyyyMMddHHmmss
$bak   = "$quick.bak-$stamp"
Copy-Item $quick $bak -Force
Write-Host "Backup => $bak"

# Load
$text = Get-Content $quick -Raw

# Try to fix inside the FIRST FilledButton(...) call
$pattern = 'FilledButton\(\s*(?<pre>.*?)onPressed\s*:\s*[^,\)]+'
$repl    = [System.Text.RegularExpressions.MatchEvaluator]{
  param($m)
  "FilledButton(" + $m.Groups['pre'].Value + "onPressed: _dirty ? _onSavePressed : null"
}

$fixed = [regex]::Replace($text, $pattern, $repl, 1, 'Singleline')

# If there was no onPressed at all (or pattern didn’t match), inject it at the start
if ($fixed -eq $text) {
  $fixed = [regex]::Replace(
    $text,
    'FilledButton\(\s*',
    'FilledButton(onPressed: _dirty ? _onSavePressed : null, ',
    1,
    'Singleline'
  )
}

# Clean up accidental double/triple commas/spaces
$fixed = [regex]::Replace($fixed, '\s*,\s*,\s*', ', ')
$fixed = [regex]::Replace($fixed, ',\s*\)', ')')      # trailing comma before ) if any

# Save
$fixed | Set-Content $quick -Encoding UTF8

# Format + analyze (nice to have)
dart format $quick | Out-Host
flutter analyze $quick | Out-Host

Write-Host "Done. onPressed normalized to _dirty ? _onSavePressed : null" -ForegroundColor Cyan
