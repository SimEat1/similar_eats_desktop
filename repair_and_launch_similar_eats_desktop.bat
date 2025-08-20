@echo off
setlocal
cd /d %~dp0
echo.
echo === Repairing Windows project files and launching ===
where flutter >nul 2>&1
if errorlevel 1 (
  echo Flutter not found in PATH. Install Flutter or open "Flutter Console".
  pause
  exit /b 1
)
flutter create .
flutter clean
flutter pub get
flutter run -d windows
pause
