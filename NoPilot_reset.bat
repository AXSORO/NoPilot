@echo off
setlocal
title NoPilot Reset - put Copilot back. Not sure why?

echo NoPilot reset will flip Copilot-related settings back on.
echo Run as administrator for HKLM and service/task changes.
echo.

:: Registry restores
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ShowCopilotButton /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableSearchBoxSuggestions /t REG_DWORD /d 0 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v DisableWebSearch /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\Shell\Copilot" /v IsCopilotAvailable /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" /v TurnOffWindowsCopilot /t REG_DWORD /d 0 /f >nul

:: Services/tasks re-enable (PowerShell assists)
powershell -NoLogo -NoProfile -Command ^
    "Get-Service -Name '*copilot*' -ErrorAction SilentlyContinue | ForEach-Object { Set-Service -Name $_.Name -StartupType Automatic -ErrorAction SilentlyContinue; Start-Service -Name $_.Name -ErrorAction SilentlyContinue }"

powershell -NoLogo -NoProfile -Command ^
    "Get-ScheduledTask | Where-Object { $_.TaskName -match 'copilot' -or $_.TaskPath -match 'copilot' } | ForEach-Object { Enable-ScheduledTask -TaskPath $_.TaskPath -TaskName $_.TaskName -ErrorAction SilentlyContinue }"

echo.
echo Settings reverted. You may need to reboot or restart Explorer for UI changes.
echo Freak.
pause
endlocal
