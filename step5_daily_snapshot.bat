@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • Daily Snapshot

for /f "tokens=1-3 delims=/- " %%a in ("%date%") do (
  set YY=%%c
  set MM=%%a
  set DD=%%b
)
set TAG=save_-%YY%%MM%%DD%

echo === Staging common files ===
git add lib\main.dart pubspec.yaml assets\ *.bat *.ps1

echo === Commit (no-op if nothing changed) ===
git commit -m "chore: daily snapshot %DATE% %TIME%" >nul 2>&1

echo === Tagging as %TAG% (will fail if it already exists) ===
git tag %TAG% -m "Daily snapshot on %DATE%"

echo Done. Current tags:
git tag -n

