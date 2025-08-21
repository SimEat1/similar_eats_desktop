@echo off
setlocal EnableExtensions
title Similar Eats • Create Feature Module Folders

echo === Creating feature module folders (no code moves yet) ===

REM Core app + shared
mkdir lib\app 2>nul
mkdir lib\core\theme 2>nul
mkdir lib\shared\widgets 2>nul
mkdir lib\shared\models 2>nul
mkdir lib\shared\data 2>nul

REM Feature areas
mkdir lib\features\onboarding 2>nul
mkdir lib\features\home 2>nul
mkdir lib\features\dinner_flow 2>nul
mkdir lib\features\map 2>nul
mkdir lib\features\ratings 2>nul
mkdir lib\features\receipts 2>nul
mkdir lib\features\profile 2>nul

REM Drop tiny readme markers so git tracks empty dirs
for %%D in (
  "lib\app"
  "lib\core\theme"
  "lib\shared\widgets"
  "lib\shared\models"
  "lib\shared\data"
  "lib\features\onboarding"
  "lib\features\home"
  "lib\features\dinner_flow"
  "lib\features\map"
  "lib\features\ratings"
  "lib\features\receipts"
  "lib\features\profile"
) do (
  if not exist %%D\README.md (
    > %%D\README.md echo Placeholder to keep folder in git.
  )
)

echo [OK] Folder skeleton created.
echo.
echo === (Optional) Commit the new folders ===
echo   git add -A ^&^& git commit -m "chore: module folder skeleton"
echo.
pause


