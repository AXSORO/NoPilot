Packaging notes (PS2EXE):

1) Install PS2EXE module (on a Windows box):
   Install-Module -Name ps2exe -Scope CurrentUser

2) Generate EXE from this folder (PowerShell, run as admin for HKLM writes when testing):
   ps2exe -inputFile .\NoPilot.ps1 -outputFile .\NoPilot.exe -noConsole:$false -iconFile "" -title "NoPilot" -requireAdmin:$true
   # -requireAdmin embeds an elevation manifest. Keep console on (-noConsole:$false) to see prompts.

3) Keep NoPilot_reset.bat alongside the EXE so users can undo changes quickly.

4) Signing (recommended to avoid SmartScreen nag):
   Use a real code-signing cert and run:
   signtool sign /fd SHA256 /a /tr http://timestamp.digicert.com /td SHA256 NoPilot.exe

5) Distribution tips:
   - Zip the contents of this folder (NoPilot.exe or NoPilot.ps1 + NoPilot_run.bat + NoPilot_reset.bat).
   - Instruct users to right-click -> Run as administrator (or just double-click EXE if manifested).
   - Windows Terminal recommended for best art rendering.
