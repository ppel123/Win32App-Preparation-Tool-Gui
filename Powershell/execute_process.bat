@ECHO OFF

REM Ensure the batch runs from its own folder (handles paths with spaces)
cd /d "%~dp0"

REM Launch the PowerShell GUI script (no elevation)
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "%~dp0win32_prep_tool_gui_ps.ps1"