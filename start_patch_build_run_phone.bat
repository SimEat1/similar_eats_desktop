@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • Patch + Phone Size + Run (verbose)

if not exist "pubspec.yaml" (
  echo [X] Run this from the project root: C:\projects\similar_eats_desktop
  pause & exit /b 1
)

REM choose python
where py >nul 2>&1 && (set _PY=py -3) || (set _PY=python)

echo.
echo === 1/5 Avatar patch ===
if not exist "tools\patch_avatar.py" (
  echo [!] tools\patch_avatar.py missing — skipping patch step
) else (
  %_PY% tools\patch_avatar.py
  if errorlevel 1 ( echo [X] Avatar patch failed & pause & exit /b 1 )
)

echo.
echo === 2/5 Phone-size runner (430x900) ===
if not exist "tools\lock_phone_size.ps1" (
  echo [X] tools\lock_phone_size.ps1 not found
  pause & exit /b 1
)
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File tools\lock_phone_size.ps1
if errorlevel 1 ( echo [X] Phone-size patch failed & pause & exit /b 1 )

echo.
echo === 3/5 flutter clean ===
flutter clean || ( echo [X] flutter clean failed & pause & exit /b 1 )

echo.
echo === 4/5 flutter pub get ===
flutter pub get || ( echo [X] pub get failed & pause & exit /b 1 )

echo.
echo === 5/5 run (Windows) ===
flutter run -d windows

echo.
echo [✓] Done.
