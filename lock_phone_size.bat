@echo off
setlocal
cd /d "%~dp0"
echo === Lock Phone Size (430x900) ===

REM --- Patch windows\runner\main.cpp to start at 430x900 ---
set MAIN=windows\runner\main.cpp
if not exist "%MAIN%" (
  echo [!] %MAIN% not found.
  pause & exit /b 1
)

REM Replace any CreateAndShow(...) with our size
powershell -NoProfile -Command ^
  "$t = Get-Content '%MAIN%';" ^
  "$t = $t -replace 'CreateAndShow\\([\\s\\S]*?\\);','CreateAndShow(L\"similar_eats_desktop\", {0, 0}, 430, 900);';" ^
  "$t | Set-Content '%MAIN%';"

echo [OK] main.cpp default size set to 430x900.

REM --- Patch windows\runner\win32_window.cpp to LOCK size (min=max=430x900) ---
set WCPP=windows\runner\win32_window.cpp
if not exist "%WCPP%" (
  echo [!] %WCPP% not found.
  pause & exit /b 1
)

REM If the WM_GETMINMAXINFO case already exists, skip insert
findstr /C:"WM_GETMINMAXINFO" "%WCPP%" >nul
if %ERRORLEVEL%==0 (
  echo [=] WM_GETMINMAXINFO already present. Skipping insert.
) else (
  echo [*] Inserting WM_GETMINMAXINFO handler to lock size...
  powershell -NoProfile -Command ^
    "$c = Get-Content '%WCPP%' -Raw;" ^
    "$c = $c -replace 'switch \\(message\\) \\{', 'switch (message) {\r\n    case WM_GETMINMAXINFO: {\r\n      MINMAXINFO* mmi = reinterpret_cast<MINMAXINFO*>(lparam);\r\n      mmi->ptMinTrackSize.x = 430; mmi->ptMinTrackSize.y = 900;\r\n      mmi->ptMaxTrackSize.x = 430; mmi->ptMaxTrackSize.y = 900;\r\n      return 0;\r\n    }';" ^
    "Set-Content '%WCPP%' $c;"
  echo [OK] Size locked to 430x900 (cannot resize).
)

echo Done. Rebuild required.
endlocal


