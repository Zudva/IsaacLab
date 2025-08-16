@echo off
setlocal
REM Forward to PowerShell launcher from Command Prompt
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_training.ps1" %*
endlocal
