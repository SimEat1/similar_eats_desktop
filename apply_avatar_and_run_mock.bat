@echo off
setlocal EnableExtensions
cd /d "%~dp0"

echo === Similar Eats Desktop • Patch Avatars + Run Mock ===
python tools\patch_avatar.py
if errorlevel 1 (
    echo [X] Avatar patch failed. Aborting.
    pause
    exit /b 1
)

echo.
echo [OK] Patch applied. Cleaning and running mock build...
flutter clean
flutter pub get
flutter run -d windows
pause



