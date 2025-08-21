@echo off
echo === Finish experiment and tag ===

for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set CURR=%%i
echo Current branch: %CURR%

if /I "%CURR%"=="master" (
  echo [X] You are on master, not an experiment branch. Aborting.
  exit /b 1
)

echo [.] Committing any staged changes...
git commit -m "chore: finish experiment" 1>nul 2>nul
if errorlevel 1 (
  echo [.] Nothing to commit.
) else (
  echo [OK] Committed.
)

for /f %%i in ('powershell -NoLogo -NoProfile -Command "Get-Date -Format yyyyMMdd"') do set TODAY=%%i
set "TAG=exp_done_%TODAY%"

git tag "%TAG%" -m "Experiment finished on %TODAY%"
echo [OK] Tagged as %TAG%
