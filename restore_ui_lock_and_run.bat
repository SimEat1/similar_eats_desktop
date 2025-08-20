@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title Similar Eats • Restore UI (step4) + Run

echo === Restore files from tag: step4_ui_lock ===
REM If you want to restore everything exactly as in step4 (code + assets + pubspec), use the 3 lines below:
git checkout tags/step4_ui_lock -- lib\main.dart
git checkout tags/step4_ui_lock -- pubspec.yaml
git checkout tags/step4_ui_lock -- assets\

IF ERRORLEVEL 1 (
  echo [X] Restore failed. Is the tag "step4_ui_lock" present?
  exit /b 1
)

echo.
echo === Flutter clean & get ===
flutter clean
flutter pub get

echo.
echo === Run (Windows) ===
flutter run -d windows
