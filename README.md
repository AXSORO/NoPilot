NoPilot - Created by AXSORO 
-------
Copilot remover tool.

What’s here
- NoPilot.ps1 — main script; run as admin for full effect.
- NoPilot_reset.bat — quick undo for Copilot/search bits (telemetry stays off).
- dist/ — bundle-ready copy of the script, launcher, reset bat, and packaging notes.
- mock/NoPilot_mock.ps1 — simulation only; previews UI on macOS/Linux, no changes.

Quick start (Windows)
- Right-click NoPilot.ps1 -> Run with PowerShell (as admin). Follow prompts.
- Optional telemetry kill switch during the run.
- Expect a reboot prompt for clean results.

Undo
- Run NoPilot_reset.bat as admin to re-enable Copilot/search bits and copilot-named services/tasks.
- Telemetry stays off by design; rerun the main script with telemetry disabled if you want it off again.

Packaging to EXE
- On Windows: see dist/README_packaging.txt for the ps2exe command and signing tips.

Notes
- Best viewed in Windows Terminal with a Unicode-friendly font for the ASCII art.
- Keep an eye out after big Windows updates; rerun if Copilot resurfaces.
