@echo off
setlocal
cd /d "%~dp0"

echo === Similar Eats Desktop • Start Mock ===

REM 1) Ensure main.dart has the mobile look (your last version)
if exist "apply_mobile_look.bat" (
  call apply_mobile_look.bat
) else (
  echo [!] apply_mobile_look.bat not found. Skipping theme apply.
)

REM 2) Force phone-sized window (430x900) so it feels like mobile
if exist "force_phone_window.bat" (
  call force_phone_window.bat
) else (
  echo [!] force_phone_window.bat not found. Continuing without resize.
)

REM 3) Clean + get deps + run
echo [*] Cleaning...
flutter clean

echo [*] Resolving packages...
flutter pub get || goto :fail

echo [*] Launching...
flutter run -d windows
goto :eof

:fail
echo [X] Failed to resolve packages. Fix pubspec or internet connection and re-run.
pause
endlocal
