@echo off
setlocal
cd /d "%~dp0"
echo === Similar Eats Desktop • NUKE & REBUILD ===

REM Kill any running exe that might block the linker
taskkill /f /im similar_eats_desktop.exe >nul 2>nul
taskkill /f /im firststop.exe >nul 2>nul

REM Clean all build/ephemeral artifacts
echo [*] Removing stale artifacts...
rd /s /q build 2>nul
rd /s /q .dart_tool 2>nul
rd /s /q windows\flutter\ephemeral 2>nul

REM Reapply mobile look (your themed main.dart)
if exist "apply_mobile_look.bat" (
  call apply_mobile_look.bat
) else (
  echo [!] apply_mobile_look.bat not found. Skipping theme apply.
)

REM Force phone window (edits runner\main.cpp only; no build here)
if exist "force_phone_window.bat" (
  call force_phone_window.bat
) else (
  echo [!] force_phone_window.bat not found. Continuing without resize.
)

REM Extra: visibly change theme color so we can confirm a fresh build
echo [*] Bumping theme seed color to deep purple to verify rebuild...
powershell -NoProfile -Command ^
  "(gc 'lib\main.dart') -replace 'seedColor:\s*Colors\.[A-Za-z0-9_]+', 'seedColor: Colors.deepPurple' | sc 'lib\main.dart'"

echo [*] flutter clean + pub get + run...
flutter clean
flutter pub get || goto :fail
flutter run -d windows -v
goto :eof

:fail
echo [X] Failed to resolve packages. Fix pubspec or connection and re-run.
pause
endlocal
