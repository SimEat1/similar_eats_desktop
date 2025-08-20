@echo off
setlocal EnableExtensions

REM --- Make sure we're in the project root ---
cd /d "%~dp0"

if not exist "pubspec.yaml" (
  echo [X] This script must live in the project root (where pubspec.yaml is).
  pause & exit /b 1
)

REM --- 1) Run the Python patch (avatars / emoji) ---
if not exist "tools\patch_avatar.py" (
  echo [X] tools\patch_avatar.py not found. Did you save it?
  pause & exit /b 1
)

echo.
echo === 1/4 PATCHING main.dart (avatars) ===
where py >nul 2>&1 && (set _PY=py -3) || (set _PY=python)
%_PY% "tools\patch_avatar.py"
if errorlevel 1 (
  echo [X] Patch failed. See any error above.
  pause & exit /b 1
)

REM --- 2) flutter clean ---
echo.
echo === 2/4 FLUTTER CLEAN ===
flutter clean || (echo [X] flutter clean failed & pause & exit /b 1)

REM --- 3) flutter pub get ---
echo.
echo === 3/4 FLUTTER PUB GET ===
flutter pub get || (echo [X] flutter pub get failed & pause & exit /b 1)

REM --- 4) Run on Windows ---
echo.
echo === 4/4 RUN (Windows) ===
flutter run -d windows

echo.
echo [✓] Done.
pause
