# Initialize Powershell Gui
Add-Type -AssemblyName System.Windows.Forms

function RunContentPrepTool {
    $exe_name = (Get-ChildItem -Path ".\App").Name
    Write-Host $exe_name
    Write-Host "-c .\App -s $exe_name -o .\"
    Start-Process .\IntuneWinAppUtil.exe -Wait -ArgumentList "-c .\App -s $exe_name -o .\"
    [void]$NewForm.Close()
}

# Create a new form
$NewForm = New-Object System.Windows.Forms.Form
$NewForm.ClientSize = '600,200'
$NewForm.text = "Win32 Preparation Tool GUI"
$NewForm.BackColor = "#ffffff"
$NewForm.AutoScale = $false


# Create the title of the GUI
$title = New-Object System.Windows.Forms.Label
$title.text = "Creating a Win32 app for Intune"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20,20)
$title.Font = 'Microsoft Sans Serif,13'

# Create the 1st option available
$option1 = New-Object System.Windows.Forms.Label
$option1.text = "
Add an application into the App folder, 
press the below button and let the application create everything for you"
$option1.AutoSize = $true
$option1.location = New-Object System.Drawing.point(20,50)
$option1.Font = 'Microsoft Sans Serif,10'

$option1Btn = New-Object System.Windows.Forms.Button
$option1Btn.BackColor = "#a4ba67"
$option1Btn.text = "Create Win32 App"
$option1Btn.Width = 180
$option1Btn.Height = 30
$option1Btn.Location = New-Object System.Drawing.Point(50,150)
$option1Btn.Font = 'Microsoft Sans Serif,10'
$option1Btn.ForeColor = "#ffffff"

$option1Btn.Add_Click({ RunContentPrepTool })

$NewForm.controls.AddRange(@($title, $option1, $option1Btn, $option2, $option2Btn))


# Display the form
[void]$NewForm.ShowDialog()

