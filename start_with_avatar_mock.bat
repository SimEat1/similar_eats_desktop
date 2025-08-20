@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • Patch + Run

if not exist tools mkdir tools

python --version >nul 2>&1
if errorlevel 1 (
  echo [X] Python not found on PATH. Install Python or reopen your terminal so PATH refreshes.
  pause
  exit /b 1
)

echo [>] Patching avatars via Python...
python tools\patch_avatar.py
if errorlevel 1 (
  echo [X] Patch failed. See message above.
  pause
  exit /b 1
)

echo.
echo === Launching Similar Eats (Desktop) ===
flutter run -d windows
echo.
pause


