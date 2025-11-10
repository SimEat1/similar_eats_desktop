@echo off
setlocal
cd /d %~dp0

REM Run the fix script, then the validator
pwsh -ExecutionPolicy Bypass -File tools\fix_validator_flags.ps1 || goto :eof
pwsh -ExecutionPolicy Bypass -File tools\validate_quick_visit.ps1

