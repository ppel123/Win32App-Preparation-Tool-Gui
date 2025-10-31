# Win32 Application Preparation Tool (Powershell GUI)

This repository contains a small PowerShell GUI that wraps Microsoft's [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) to create .intunewin packages for Intune with minimal command-line interaction.

The GUI expects the Microsoft tool `IntuneWinAppUtil.exe` to be present in the same folder as the script.

## What this script does
- Provides a small Windows Forms GUI (implemented in PowerShell) to prepare Win32 apps for Microsoft Intune using `IntuneWinAppUtil.exe`.
- Lets users browse/select:
  - Source folder (the setup folder that contains the setup files and other content)
  - Setup file (the .exe or .msi installer inside the source folder)
  - Output folder (defaults to the script location)
  - Optionally include a catalog folder (Yes/No) and choose the catalog folder path
- Runs `IntuneWinAppUtil.exe` with the chosen parameters and `-q` (quiet) to generate the .intunewin file.
- Logs actions, decisions and errors to `win32_prep_tool_gui.log` in the script folder. If logging fails, messages fall back to console output.
- Shows success/error MessageBox dialogs so a non-technical user can see results.

## Files in this folder
- `App/` — sample or user-provided folder where the setup files can be placed (user-managed).
- `IntuneWinAppUtil.exe` — Microsoft Win32 Content Prep Tool. Can be found in Microsoft's official GitHub page ([Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool)) or documentation ([Microsoft's documentation](https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-prepare)). Place the latest version here before running the GUI.
- `win32_prep_tool_gui_ps.ps1` — PowerShell script that implements the GUI and runs the packaging tool.
- `execute_process.bat` — optional convenience batch to start the PowerShell script.
- `win32_prep_tool_gui.log` — generated at runtime; contains timestamps and a log of script actions.

## Prerequisites
- Windows with PowerShell (the script uses Windows Forms via .NET).
- `IntuneWinAppUtil.exe` downloaded from Microsoft's repository and placed in the same folder as the script.
- Sufficient file system permissions to read the source and catalog folders and write to the output folder.

## How to run
Run the tool in one of the following ways (run elevated / as Administrator where required):

- Open `win32_prep_tool_gui_ps.ps1` in an elevated PowerShell ISE or Visual Studio Code.
- Or execute `execute_process.bat` as Administrator (right-click → "Run as administrator").

Then use the GUI:

<img width="1017" height="502" alt="win32app_preparation_tool_gui" src="https://github.com/user-attachments/assets/c5e807b2-22a7-4a75-82d2-c8571d2facbd" />


1. Click "Browse..." next to Source folder and select the folder that contains the installer and related files.
2. Click "Browse..." next to Setup file and select the setup .exe or .msi file.
3. Confirm or change the Output folder (defaults to the script folder).
4. Choose whether to include a catalog folder (Yes/No). If Yes, select the catalog folder.
5. Click "Package (Run IntuneWinAppUtil)".

## Logging
All operations are appended to `win32_prep_tool_gui.log` in the script folder with timestamps and levels (INFO/WARN/ERROR). The GUI also displays MessageBoxes for notable success/failure conditions.

## Notes & behavior details
- The script uses `-q` (quiet) when calling `IntuneWinAppUtil.exe` so interactive prompts are suppressed.

## Troubleshooting
- If nothing happens when you click "Package", check `win32_prep_tool_gui.log` for errors.
- If `IntuneWinAppUtil.exe` is missing, download it from Microsoft's repo and place it alongside the script.
- If you see permission errors, run the PowerShell session as a user with permissions to create files in the output folder.

## License / attribution
This GUI is a convenience wrapper that calls Microsoft's Win32 Content Prep Tool. The underlying packaging functionality is provided by Microsoft; please consult their repository and documentation for licensing and further details:
- https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool

- https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-prepare
