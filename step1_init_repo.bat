@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo === Step 1: Initialize repo and first snapshot ===

:: Check git
where git >nul 2>nul
if errorlevel 1 (
  echo [X] Git is not installed or not on PATH. Install Git for Windows first.
  exit /b 1
)

:: Create .gitignore if missing
if not exist ".gitignore" (
  > ".gitignore" (
    echo # Flutter / Dart
    echo .dart_tool/
    echo .packages
    echo .flutter-plugins
    echo .flutter-plugins-dependencies
    echo .metadata
    echo pubspec.lock
    echo
    echo # Builds
    echo build/
    echo ios/Flutter/Flutter.podspec
    echo ios/Pods/
    echo macos/Pods/
    echo linux/flutter/ephemeral/
    echo windows/flutter/ephemeral/
    echo
    echo # VSCode / IntelliJ
    echo .idea/
    echo .vscode/
    echo
    echo # Misc
    echo *.iml
    echo *.log
    echo *.tmp
  )
  echo [OK] Wrote .gitignore
) else (
  echo [. ] .gitignore already exists - leaving as-is
)

:: Init repo if needed
if not exist ".git" (
  git init
  if errorlevel 1 (
    echo [X] git init failed
    exit /b 1
  )
  echo [OK] git init
) else (
  echo [. ] Repo already initialized
)

:: Add everything (respecting .gitignore) and commit
git add -A
if errorlevel 1 (
  echo [X] git add failed
  exit /b 1
)

:: Only commit if there is something to commit
git diff --cached --quiet
if errorlevel 1 (
  git commit -m "chore: initial snapshot"
  if errorlevel 1 (
    echo [X] git commit failed
    exit /b 1
  )
  echo [OK] Committed: chore: initial snapshot
) else (
  echo [. ] Nothing new to commit (working tree clean)
)

echo === Step 1 done. Repo is ready. ===
endlocal
