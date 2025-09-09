@echo off
setlocal
set PROJ=C:\projects\similar_eats_desktop
powershell -ExecutionPolicy Bypass -File "%PROJ%\tools\make-feature.ps1" %*
endlocal

