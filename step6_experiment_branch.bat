@echo off
echo === Step 6: Create experiment branch ===

rem Use PowerShell to grab YYYYMMDD format
for /f %%i in ('powershell -NoLogo -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i

set "BRANCH_NAME=feature/experiment-%TODAY%"

echo [.] Creating new branch: %BRANCH_NAME%
git checkout -b "%BRANCH_NAME%"
if errorlevel 1 (
  echo [X] Failed to create branch.
  exit /b 1
)
echo [OK] Now on %BRANCH_NAME%

