# Win32 Application Preparation Tool 

This tool is based on and uses Microsoft's [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool). More details about the tool itself can be found in their [Github repo](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) or on the [Microsoft's page](https://docs.microsoft.com/en-us/mem/intune/apps/apps-win32-prepare). I suggest downloading and using the latest available version (found on the previously mentioned sites) of the tool before using this GUI.

## GUI
While scrolling and searching information in different Intune forums and groups, I saw several questions and requests about a Win32 Preparation GUI tool, with which users with little or no command prompt experience can prepare their applications easily for uploading to Intune.  
Having that in mind I created this repo, where I uploaded a very very simple GUI that can prepare the application just by pressing a button.  
I created this GUI in Python (personal preference) and in Powershell (I recommend using this one because it is independent of any additional installation). Below you can find a description of the way this application is functioning. 

## How to use?
First let's see the way the application is structured and how the user can run it.

![Imgur](https://i.imgur.com/2lKYrxGl.png)

The files in the application's folder are:
1. **App folder** in which the user adds the desired application (.exe or .msi) to prepare for Intune.
2. **IntuneWinAppUtil.exe**, Microsoft's tool for preparing the application for Intune.
3. **win32_prep_tool_gui_ps.ps1**, Powershell script that creates the GUI and runs the **IntuneWinAppUtil.exe** file. All the required parameters are automatically passed and there is no need for user interaction.
4. **execute_process.bat**, a .bat file for convenience. The user can download this repo and instantly prepare an application for Intune by just running this .bat file.

## Demonstration
Let's see the tool in action.  
#### First Step 
The user selects the application they want and places it in the **App** folder.

![Imgur](https://i.imgur.com/fag7FGPl.png)  

#### Second Step
The user just runs the **execute_process.bat** file and presses the button "Create Win32 App".

![Imgur](https://i.imgur.com/tc7lM2ml.png)  

#### Last Step
Upload the generated .intunewin file to Intune.
Ready!
