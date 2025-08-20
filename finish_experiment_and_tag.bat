@echo off
echo === Finish experiment and tag ===

:: Check branch
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set branch=%%i
echo Current branch: %branch%

if "%branch%"=="master" (
  echo [X] You are on master, not an experiment branch. Aborting.
  exit /b 1
)

:: Commit staged changes if any
echo [.] Committing any staged changes...
git commit -m "wip: experiment snapshot" || echo [.] Nothing to commit.

:: Get date as YYYYMMDD using PowerShell
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set yyyymmdd=%%i

set tag=exp_done_%yyyymmdd%
git tag %tag% -m "Experiment finished on %yyyymmdd%"

echo [OK] Tagged as %tag%
