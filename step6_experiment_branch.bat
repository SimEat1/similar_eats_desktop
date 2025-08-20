@echo off
echo === Step 6: Create experiment branch ===

:: 1) Make sure working tree is clean
git status --porcelain
if errorlevel 1 (
    echo [X] Git status failed. Aborting.
    exit /b 1
)

for /f "tokens=*" %%i in ('git status --porcelain') do (
    echo [X] Working tree is dirty! Please commit or stash changes first.
    exit /b 1
)

:: 2) Generate branch name with date
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i
set yyyymmdd=%datetime:~0,8%
set branch=feature/experiment-%yyyymmdd%

:: 3) Create and switch to branch
echo [.] Creating new branch: %branch%
git checkout -b %branch%
if errorlevel 1 (
    echo [X] Failed to create branch.
    exit /b 1
)

echo [OK] Switched to %branch%
echo You can now work safely here. Commit often!
