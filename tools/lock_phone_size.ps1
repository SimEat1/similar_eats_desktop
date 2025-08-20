# Lock the Win32 runner window to ~phone size (430x900).
$ErrorActionPreference = 'Stop'
$runner = Join-Path $PSScriptRoot '..\windows\runner\main.cpp' | Resolve-Path
if (-not (Test-Path $runner)) { Write-Error "runner/main.cpp not found: $runner" }

$code = Get-Content -Raw $runner

# Replace any CreateAndShow(..., width, height) with our size.
$code = $code -replace 'CreateAndShow\([^,]+,\s*\{[^\}]+\},\s*\d+,\s*\d+\)',
                       'CreateAndShow(L"similar_eats_desktop", {0, 0}, 430, 900)'

# Ensure SetQuitOnClose(true) exists (optional safe insert if missing).
if ($code -notmatch 'SetQuitOnClose\(true\)') {
  $code = $code -replace '(CreateAndShow\(.*?\);\s*)',
                        "`$1`n  window.SetQuitOnClose(true);"
}

Set-Content -Encoding UTF8 $runner $code
Write-Host "[OK] Window size locked to 430x900 in runner/main.cpp"
