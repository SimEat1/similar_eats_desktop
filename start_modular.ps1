<#  start_modular.ps1
    Runs the modular entry, safely kills any running exe, cleans, gets deps, and launches.
    Usage:
      ./start_modular.ps1
      ./start_modular.ps1 -Target lib/main_modular.dart
      ./start_modular.ps1 -Phone        # (optional flag you can use later)
#>

param(
  [string]$Target = "lib/main_modular.dart",
  [switch]$Phone
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here

function Info($msg) { Write-Host "[*] $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "[OK] $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "[X] $msg" -ForegroundColor Red }

try {
  Info "Killing any running app..."
  Get-Process similar_eats_desktop -ErrorAction SilentlyContinue | Stop-Process -Force

  # Sometimes the exe can be locked; try deleting if it exists
  $exePath = Join-Path $here "build/windows/x64/runner/Debug/similar_eats_desktop.exe"
  if (Test-Path $exePath) {
    Start-Sleep -Milliseconds 250
    Remove-Item $exePath -Force -ErrorAction SilentlyContinue
  }

  # Verify target
  if (!(Test-Path $Target)) {
    Info "Target '$Target' not found; falling back to lib/main.dart"
    $Target = "lib/main.dart"
  }

  Info "Flutter clean..."
  flutter clean | Out-Host

  Info "Pub get..."
  flutter pub get | Out-Host

  # Optional: add flags later (e.g., force phone layout) via dart-define
  $defines = @()
  if ($Phone) { $defines += "--dart-define=FORCE_PHONE_WINDOW=true" }

$exe  = "flutter"
$args = @("run","-d","windows","-t",$Target) + $defines
Info "Launching: $exe $($args -join ' ')"
& $exe @args

  if ($LASTEXITCODE -ne 0) { throw "flutter run failed ($LASTEXITCODE)" }
  Ok "App running."
}
catch {
  Fail $_.Exception.Message
  exit 1
}
