@echo off
echo [.] Backing up lib\main.dart to lib\main.dart.bak
copy /Y lib\main.dart lib\main.dart.bak >nul

echo [.] Patching clickable prompt...
powershell -ExecutionPolicy Bypass -File patch_prompt.ps1

echo [.] Running Flutter...
flutter run -d windows
