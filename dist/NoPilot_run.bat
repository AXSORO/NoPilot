@echo off
setlocal
title NoPilot - run as admin
echo Starting NoPilot (will prompt for UAC)...
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0NoPilot.ps1"
endlocal
