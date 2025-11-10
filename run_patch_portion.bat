@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0patch_portion.ps1"
if %errorlevel% neq 0 (
  echo.
  echo Patch failed. See messages above.
  exit /b %errorlevel%
)
echo.
echo Patch completed.
endlocal
