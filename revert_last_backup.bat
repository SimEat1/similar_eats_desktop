@echo off
setlocal
set FILE=lib\features\visits\screens\quick_visit_screen.dart

for /f "delims=" %%F in ('dir /b /od "%FILE%.bak-*"') do set LAST=%%F

if "%LAST%"=="" (
  echo No backup found for %FILE%
  exit /b 1
)

copy /y "%LAST%" "%FILE%"
echo Restored => %LAST%

endlocal
