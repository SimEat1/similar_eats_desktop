@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo === Similar Eats Desktop • MOBILE MOCK LAUNCH ===

rem 1) Apply phone-size patch
powershell -ExecutionPolicy Bypass -NoProfile -File "tools\lock_phone_size.ps1" || (
  echo [X] Failed to apply phone size patch.
  pause
  exit /b 1
)

rem 2) Run the app
flutter run -d windows
