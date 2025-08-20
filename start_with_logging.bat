@echo off
setlocal
cd /d "%~dp0"
echo === Similar Eats Desktop • START WITH LOGGING ===

REM Kill any stuck EXEs blocking linker
taskkill /f /im similar_eats_desktop.exe >nul 2>nul
taskkill /f /im firststop.exe >nul 2>nul

REM Ensure mobile look + phone size are applied
if exist "apply_mobile_look.bat" call apply_mobile_look.bat

if exist "lock_phone_size.bat" (
  call lock_phone_size.bat
) else (
  echo [!] lock_phone_size.bat not found. (Window will be resizable.)
)

REM Clean & restore & run with verbose output captured to a log
set LOG=.last_run.log
echo [*] Cleaning...
flutter clean  1>>%LOG% 2>>&1

echo [*] Pub get...
flutter pub get  1>>%LOG% 2>>&1
if errorlevel 1 (
  echo [X] pub get failed. Opening log...
  notepad %LOG%
  pause & exit /b 1
)

echo [*] Launching (verbose)...
flutter run -d windows -v  1>>%LOG% 2>>&1
if errorlevel 1 (
  echo [X] Build/run failed. Opening log...
  notepad %LOG%
  pause & exit /b 1
)

echo [OK] Launched. (Log at %LOG%)
endlocal

