# add_receipt_ocr.ps1
$ErrorActionPreference = "Stop"

function Backup-And-Write($path, $content) {
  if (Test-Path $path) {
    Copy-Item $path "$path.bak" -Force
    Write-Host "Backup: $path -> $path.bak"
  }
  Set-Content -Path $path -Value $content -Encoding UTF8 -NoNewline
  Write-Host "Wrote: $path"
}

# --- sanity: project root
if (-not (Test-Path ".\pubspec.yaml")) { throw "Run this from your project root (pubspec.yaml not found)." }

# --- Read pubspec and ensure file_picker under dependencies
$pubspec = Get-Content -Raw ".\pubspec.yaml"

# If there's no dependencies section, bail (very unusual)
if ($pubspec -notmatch "(?ms)^\s*dependencies:\s*$") {
  throw "Couldn't find a 'dependencies:' section in pubspec.yaml"
}

# Add or update file_picker: ^8.0.0
$line = "  file_picker: ^8.0.0"
if ($pubspec -match "(?ms)^\s*dependencies:\s*(.*?)(^\S|\Z)") {
  $block    = $Matches[1]
  $afterKey = $Matches[2]

  if ($block -match "(?m)^\s*file_picker:\s*.+$") {
    # replace existing version line
    $newBlock = ($block -replace "(?m)^\s*file_picker:\s*.+$", $line)
  } else {
    # append under dependencies
    # ensure block ends with newline
    if ($block -notmatch "`n$") { $block = $block + "`n" }
    $newBlock = $block + $line + "`n"
  }

  # rebuild pubspec
  $pubspec = $pubspec -replace [regex]::Escape($Matches[1]), [System.Text.RegularExpressions.Regex]::Escape($newBlock) -replace "\\", "\"
}

Backup-And-Write ".\pubspec.yaml" $pubspec

# --- flutter pub get
Write-Host "Running flutter pub get..."
flutter pub get | Write-Host

Write-Host "`nAll set. Next:"
Write-Host "  1) If you haven't yet, install Tesseract with Chocolatey:"
Write-Host "       choco install tesseract --version=5.3.3"
Write-Host "     (then open a NEW PowerShell window so PATH updates)"
Write-Host "  2) Run the app:"
Write-Host "       flutter run -d windows"
Write-Host "  3) Home → Scan receipt → click the photo icon, pick an image → OCR runs."



