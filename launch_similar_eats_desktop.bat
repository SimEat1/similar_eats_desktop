@echo off
setlocal
cd /d %~dp0
echo.
echo === Launching Similar Eats Desktop ===
where flutter >nul 2>&1
if errorlevel 1 (
  echo Flutter not found in PATH. Install Flutter or open "Flutter Console".
  pause
  exit /b 1
)
flutter pub get
flutter run -d windows
echo.
echo (Tip) Close this window after Flutter finishes if it doesn't exit.
pause
