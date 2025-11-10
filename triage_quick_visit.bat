@echo off
REM Thin wrapper around the PowerShell helper
set PS=tools\triage_quick_visit.ps1
if not exist %PS% (
  echo Missing %PS%
  exit /b 1
)

if "%1"=="" (
  pwsh -NoProfile -File %PS%
  exit /b %ERRORLEVEL%
)

REM pass all args through
pwsh -NoProfile -File %PS% %*

