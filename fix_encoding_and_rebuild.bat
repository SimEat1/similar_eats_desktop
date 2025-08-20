@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • Fix encoding + Rebuild

echo === 1/2 Fixing text encoding in lib\main.dart ===
powershell -NoLogo -NoProfile -Command ^
  "$p='lib/main.dart';" ^
  "$c=Get-Content -Raw $p;" ^
  "$c=$c.Replace('â€¢','•').Replace('â€“','–').Replace('â€”','—').Replace('â€˜','‘').Replace('â€™','’').Replace('â€œ','“').Replace('â€ ','”').Replace('â˜…','★').Replace('â˜†','☆').Replace('Ã—','×').Replace('Â·','·');" ^
  "$c=$c -replace 'emoji:\s*''[^'']*''','';" ^
  "Set-Content -Encoding UTF8 $p $c;" ^
  "Write-Host '[OK] Saved as UTF-8 and cleaned common mojibake.'"

if errorlevel 1 (
  echo [X] Could not patch lib\main.dart
  pause
  exit /b 1
)

echo.
echo === 2/2 Rebuild & run (Windows) ===
flutter clean || goto :e
flutter pub get || goto :e
flutter run -d windows
goto :end

:e
echo [X] Flutter step failed.
pause
:end
