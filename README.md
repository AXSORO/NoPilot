NoPilot - Simple Copilot removal tool (somewhat WIP)
-------
Files
- NoPilot.ps1 — main script to be ran as admin from powershell
- NoPilot_reset.bat — restores changes, except telemetry disable tasks
- dist/ — wip for exe package
- mock/NoPilot_mock.ps1 — visual sim test, working from macOS

Quick start (Windows)
- Windows Key + X -> Windows PowerShell (Admin) -> Navigate to directory and run script
- If you get an error for not being able to run scripts, check that set-executionpolicy setting is "bypass" or "unrestricted" 
- Optional telemetry disable prompts
- reboot

Undo
- Run NoPilot_reset.bat as admin to restore copilot changes
- Telemetry stays off by design; rerun the main script with telemetry disabled if you want it off again.

Packaging to EXE
- Currently a WIP as per the dist/ directory

Notes
- Run in Windows Terminal, not legacy command window 
- This was tested on Windows 11 25H2 - future updates might need the script to be reworked. 
