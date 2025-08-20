@echo off
setlocal
cd /d "%~dp0"

set RUNNER=windows\runner\main.cpp

if not exist "%RUNNER%" (
  echo [!] %RUNNER% not found. Are you in C:\projects\similar_eats_desktop ?
  pause & exit /b 1
)

REM Replace any CreateAndShow size with 430 x 900 (phone-like)
powershell -NoProfile -Command ^
  "(Get-Content '%RUNNER%') -replace 'CreateAndShow\\(.*?,\\s*\\d+,\\s*\\d+\\)', 'CreateAndShow(L\"similar_eats_desktop\", {0, 0}, 430, 900)' | Set-Content '%RUNNER%'"

echo [OK] Window size set to 430x900. This script does not run Flutter.
endlocal


