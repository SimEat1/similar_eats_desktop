@echo off
setlocal
cd /d "%~dp0"
echo === Similar Eats Desktop • SAFE START ===

REM 1) Apply mobile look (writes lib\main.dart)
if exist "apply_mobile_look.bat" (
  call apply_mobile_look.bat
) else (
  echo [!] apply_mobile_look.bat not found. Skipping theme apply.
)

REM 2) Force phone window (edits runner\main.cpp only)
if exist "force_phone_window.bat" (
  call force_phone_window.bat
) else (
  echo [!] force_phone_window.bat not found. Continuing without resize.
)

REM 3) Clean & get packages
echo [*] Cleaning...
flutter clean

echo [*] Resolving packages...
flutter pub get || goto :fail

REM 4) Run on Windows with verbose output so errors are visible
echo [*] Launching app...
flutter run -d windows -v
goto :eof

:fail
echo [X] Failed to resolve packages. Fix pubspec or your connection, then re-run.
pause
endlocal


