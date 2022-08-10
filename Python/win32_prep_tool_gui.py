import PySimpleGUI as sg
import sys
import subprocess
import os

def create_win32_app():
    # get application name from the App folder
    # print(os.listdir('.\\App')[0])
    # print('IntuneWinAppUtil.exe' + '-c' + '.\\App' + '-s ' + str(os.listdir('.\\App')[0]) + ' -o' + '.\\')
    
    subprocess.run(['IntuneWinAppUtil.exe', '-c', '.\\App', '-s', os.listdir('.\\App')[0], '-o', '.\\'], capture_output=True)
    return True
    
    

def create_gui():

    layout = [[sg.Text("Place the wanted application in the App folder and the press Submit")],
              [sg.Text("Wait for the Success Popup to pop and you are ready")],
              [sg.Submit()]
              ]
    
    window = sg.Window('Win32 Prep Tool Gui', layout)

    while True:
        event, values = window.read()

        if event in (None, 'Exit'):
            break
        else:
            create_win32_app()
            window.close()
            sg.popup("Success: intunewin created successfully")

if __name__ == "__main__":
    create_gui()
