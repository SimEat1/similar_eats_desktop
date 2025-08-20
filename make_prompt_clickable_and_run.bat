@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo [.] Patching prompt...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\patch_prompt.ps1"
if errorlevel 2 (
  echo [!] Patch couldn't find the prompt Text(_prompt ...). If you recently changed that area, I can adjust the matcher.
  goto :after
)
if errorlevel 1 (
  echo [X] Patch failed.
  exit /b 1
)

:after
echo.
echo [.] Building & running...
flutter run -d windows
endlocal
