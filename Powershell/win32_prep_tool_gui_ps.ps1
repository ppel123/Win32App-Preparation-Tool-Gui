# Initialize Powershell Gui
Add-Type -AssemblyName System.Windows.Forms

# Determine script directory and log file
if ($PSScriptRoot) { $scriptDir = $PSScriptRoot } else { $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition }
$LogFilePath = Join-Path $scriptDir 'win32_prep_tool_gui.log'

function Write-Log {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    try {
        "{0} [{1}] {2}" -f $timestamp, $Level, $Message | Out-File -FilePath $LogFilePath -Encoding utf8 -Append
    } catch {
        # If logging fails, fall back to console so errors are still visible
        Write-Host "Logging failed: $($_.Exception.Message)"
        Write-Host "{0} [{1}] {2}" -f $timestamp, $Level, $Message
    }
}

Write-Log "Script started"

function RunContentPrepTool {
    Write-Log "RunContentPrepTool started"
    try {
        $appPath = Join-Path $scriptDir 'App'
        Write-Log "Looking for content in: $appPath"

        if (-not (Test-Path $appPath)) {
            throw "App folder not found at: $appPath"
        }

        $contentList = Get-ChildItem -Path $appPath | Sort-Object -Property PSIsContainer -Descending
        if (-not $contentList -or $contentList.Count -eq 0) {
            throw "No files or folders were found in the App folder"
        }

        if ($contentList.Count -gt 1) {
            Write-Log "Multiple items found in App folder. Will process the first item: $($contentList[0].Name)"
        }

        $content = $contentList[0]
        $content_name = $content.Name
        $content_attributes = $content.Attributes.ToString()
        Write-Log "Selected content: $content_name (Attributes: $content_attributes)"

        $intuneUtil = Join-Path $scriptDir 'IntuneWinAppUtil.exe'
        if (-not (Test-Path $intuneUtil)) {
            throw "IntuneWinAppUtil.exe was not found in script folder: $intuneUtil"
        }

        if ($content_name.EndsWith('.exe') -or $content_name.EndsWith('.msi')){
            Write-Log "Detected package file: $content_name"
            $arguments = "-c .\App -s $content_name -o .\"
            Write-Log "Executing: $intuneUtil $arguments"
            $proc = Start-Process -FilePath $intuneUtil -ArgumentList $arguments -Wait -PassThru
            $exit = $proc.ExitCode
            Write-Log "IntuneWinAppUtil exit code: $exit"
            if ($exit -ne 0) { throw "IntuneWinAppUtil failed with exit code $exit" }
        }
        elseif (-not($content_name.EndsWith('.exe') -or $content_name.EndsWith('.msi')) -and ($content_attributes).Contains("Directory")){
            Write-Log "Detected directory: $content_name"
            $folderPath = Join-Path $appPath $content_name
            $inside_folder_content_exe = Get-ChildItem -Path $folderPath -Filter "*.exe" | Where-Object { $_.Name.ToUpper() -notlike 'SERVICEUI.*' }
            if (-not $inside_folder_content_exe) {
                throw "No suitable .exe found in folder: $folderPath"
            }
            $exeName = $inside_folder_content_exe[0].Name
            Write-Log "Using internal exe: $exeName"
            $arguments = "-c .\App\$content_name -s $exeName -o .\"
            Write-Log "Executing: $intuneUtil $arguments"
            $proc = Start-Process -FilePath $intuneUtil -ArgumentList $arguments -Wait -PassThru
            $exit = $proc.ExitCode
            Write-Log "IntuneWinAppUtil exit code: $exit"
            if ($exit -ne 0) { throw "IntuneWinAppUtil failed with exit code $exit" }
        }
        else {
            Write-Log "Unrecognized content type: $content_name" "ERROR"
            throw "Unrecognized content type: $content_name"
        }

        Write-Log "Packaging succeeded. Closing form"
        if ($script:NewForm -ne $null) { [void]$script:NewForm.Close() }
        [System.Windows.Forms.MessageBox]::Show('Win32 packaging completed successfully.','Success',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) > $null
    }
    catch {
        $err = $_.Exception.Message
        Write-Log "Error in RunContentPrepTool: $err" "ERROR"
        [System.Windows.Forms.MessageBox]::Show("Error: $err","Error",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) > $null
    }
    finally {
        Write-Log "RunContentPrepTool finished"
    }
}

# Create a new form
$script:NewForm = New-Object System.Windows.Forms.Form
$script:NewForm.ClientSize = '1000,460'
$script:NewForm.text = "Win32 Preparation Tool GUI"
$script:NewForm.BackColor = "#ffffff"
$script:NewForm.AutoScale = $false


# Create the title of the GUI
$title = New-Object System.Windows.Forms.Label
$title.text = "Creating a Win32 app for Intune"
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(20,20)
$title.Font = 'Microsoft Sans Serif,13'

# Create the 1st option available

# --- Source folder control ---
$lblSource = New-Object System.Windows.Forms.Label
$lblSource.text = '1) Source folder (setup folder):'
$lblSource.AutoSize = $true
$lblSource.Location = New-Object System.Drawing.Point(20,60)
$lblSource.Font = 'Microsoft Sans Serif,10'

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Width = 600
$txtSource.Location = New-Object System.Drawing.Point(20,85)

$btnBrowseSource = New-Object System.Windows.Forms.Button
$btnBrowseSource.text = 'Browse...'
$btnBrowseSource.Location = New-Object System.Drawing.Point(640,82)
$btnBrowseSource.Width = 80
$btnBrowseSource.Add_Click({
    Write-Log "Browse Source clicked"
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.SelectedPath = (Join-Path $scriptDir 'App')
    if ($fbd.ShowDialog() -eq 'OK') { $txtSource.Text = $fbd.SelectedPath; Write-Log "Source selected: $($txtSource.Text)" }
})

# --- Setup file control ---
$lblSetup = New-Object System.Windows.Forms.Label
$lblSetup.text = '2) Setup file (exe or msi):'
$lblSetup.AutoSize = $true
$lblSetup.Location = New-Object System.Drawing.Point(20,120)
$lblSetup.Font = 'Microsoft Sans Serif,10'

$txtSetup = New-Object System.Windows.Forms.TextBox
$txtSetup.Width = 520
$txtSetup.Location = New-Object System.Drawing.Point(20,145)

$btnBrowseSetup = New-Object System.Windows.Forms.Button
$btnBrowseSetup.text = 'Browse...'
$btnBrowseSetup.Location = New-Object System.Drawing.Point(540,142)
$btnBrowseSetup.Width = 80
$btnBrowseSetup.Add_Click({
    Write-Log "Browse Setup clicked"
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = 'Setup Files (*.exe;*.msi)|*.exe;*.msi|All files (*.*)|*.*'
    $ofd.InitialDirectory = (Join-Path $scriptDir 'App')
    if ($ofd.ShowDialog() -eq 'OK') { $txtSetup.Text = $ofd.FileName; Write-Log "Setup selected: $($txtSetup.Text)" }
})

# --- Output folder control ---
$lblOutput = New-Object System.Windows.Forms.Label
$lblOutput.text = '3) Output folder:'
$lblOutput.AutoSize = $true
$lblOutput.Location = New-Object System.Drawing.Point(20,180)
$lblOutput.Font = 'Microsoft Sans Serif,10'

$txtOutput = New-Object System.Windows.Forms.TextBox
$txtOutput.Width = 600
$txtOutput.Location = New-Object System.Drawing.Point(20,205)
$txtOutput.Text = $scriptDir

$btnBrowseOutput = New-Object System.Windows.Forms.Button
$btnBrowseOutput.text = 'Browse...'
$btnBrowseOutput.Location = New-Object System.Drawing.Point(640,205)
$btnBrowseOutput.Width = 80
$btnBrowseOutput.Add_Click({
    Write-Log "Browse Output clicked"
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.SelectedPath = $txtOutput.Text
    if ($fbd.ShowDialog() -eq 'OK') { $txtOutput.Text = $fbd.SelectedPath; Write-Log "Output selected: $($txtOutput.Text)" }
})

# --- Catalog selection ---
$lblCatalog = New-Object System.Windows.Forms.Label
$lblCatalog.text = '4) Include catalog folder?'
$lblCatalog.AutoSize = $true
$lblCatalog.Location = New-Object System.Drawing.Point(20,240)
$lblCatalog.Font = 'Microsoft Sans Serif,10'

$rbCatalogYes = New-Object System.Windows.Forms.RadioButton
$rbCatalogYes.Text = 'Yes'
$rbCatalogYes.Location = New-Object System.Drawing.Point(220,265)
$rbCatalogYes.AutoSize = $true

$rbCatalogNo = New-Object System.Windows.Forms.RadioButton
$rbCatalogNo.Text = 'No'
$rbCatalogNo.Location = New-Object System.Drawing.Point(280,265)
$rbCatalogNo.AutoSize = $true
$rbCatalogNo.Checked = $true

# Catalog folder textbox + browse (optional)
$txtCatalog = New-Object System.Windows.Forms.TextBox
$txtCatalog.Width = 520
$txtCatalog.Location = New-Object System.Drawing.Point(20,290)
$txtCatalog.Enabled = $false

$btnBrowseCatalog = New-Object System.Windows.Forms.Button
$btnBrowseCatalog.text = 'Browse...'
$btnBrowseCatalog.Location = New-Object System.Drawing.Point(540,287)
$btnBrowseCatalog.Width = 80
$btnBrowseCatalog.Enabled = $false
$btnBrowseCatalog.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($fbd.ShowDialog() -eq 'OK') { $txtCatalog.Text = $fbd.SelectedPath; Write-Log "Catalog selected: $($txtCatalog.Text)" }
})

$rbCatalogYes.Add_CheckedChanged({ if ($rbCatalogYes.Checked) { $txtCatalog.Enabled = $true; $btnBrowseCatalog.Enabled = $true; Write-Log 'Catalog option set to Yes' } })
$rbCatalogNo.Add_CheckedChanged({ if ($rbCatalogNo.Checked) { $txtCatalog.Enabled = $false; $btnBrowseCatalog.Enabled = $false; Write-Log 'Catalog option set to No' } })

# --- Package button ---
$btnPackage = New-Object System.Windows.Forms.Button
$btnPackage.text = 'Package (Run IntuneWinAppUtil)'
$btnPackage.Width = 300
$btnPackage.Height = 40
$btnPackage.Location = New-Object System.Drawing.Point(20,330)
$btnPackage.BackColor = '#2d89ef'
$btnPackage.ForeColor = '#ffffff'
$btnPackage.Font = 'Microsoft Sans Serif,10'

$btnPackage.Add_Click({
    Write-Log 'Package button clicked'
    try {
        # Basic validation
        if ([string]::IsNullOrWhiteSpace($txtSource.Text)) { throw 'Source folder is required' }
        if ([string]::IsNullOrWhiteSpace($txtSetup.Text)) { throw 'Setup file is required' }
        if (-not (Test-Path $txtSource.Text)) { throw "Source folder not found: $($txtSource.Text)" }
        if (-not (Test-Path $txtSetup.Text)) { throw "Setup file not found: $($txtSetup.Text)" }
        if (-not (Test-Path $txtOutput.Text)) { New-Item -ItemType Directory -Path $txtOutput.Text -Force | Out-Null; Write-Log "Created output folder: $($txtOutput.Text)" }

        $intuneUtil = Join-Path $scriptDir 'IntuneWinAppUtil.exe'
        if (-not (Test-Path $intuneUtil)) { throw "IntuneWinAppUtil.exe not found in script folder: $intuneUtil" }

        $sourceFolderArg = $txtSource.Text
        $setupFileArg = Split-Path -Leaf $txtSetup.Text
        $outputFolderArg = $txtOutput.Text
        $catalogArg = ''
        if ($rbCatalogYes.Checked) {
            if ([string]::IsNullOrWhiteSpace($txtCatalog.Text) -or -not (Test-Path $txtCatalog.Text)) { throw 'Catalog folder selected but path is invalid or empty' }
            $catalogArg = " -a $($txtCatalog.Text)"
        }

        $arguments = "-c `"$sourceFolderArg`" -s `"$setupFileArg`" -o `"$outputFolderArg`"$catalogArg -q"
        Write-Log "Running IntuneWinAppUtil: $intuneUtil $arguments"
        $proc = Start-Process -FilePath $intuneUtil -ArgumentList $arguments -Wait -PassThru
        Write-Log "IntuneWinAppUtil exit code: $($proc.ExitCode)"
        if ($proc.ExitCode -ne 0) { throw "IntuneWinAppUtil failed with exit code $($proc.ExitCode)" }

        [System.Windows.Forms.MessageBox]::Show('Packaging completed successfully.','Success',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Information) > $null
    }
    catch {
        Write-Log "Packaging error: $($_.Exception.Message)" 'ERROR'
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)",'Error',[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Error) > $null
    }
})


# Add controls to the form (order matters for tabbing)
$script:NewForm.controls.AddRange(@(
    $title,
    $lblSource,$txtSource,$btnBrowseSource,
    $lblSetup,$txtSetup,$btnBrowseSetup,
    $lblOutput,$txtOutput,$btnBrowseOutput,
    $lblCatalog,$rbCatalogYes,$rbCatalogNo,$txtCatalog,$btnBrowseCatalog,
    $btnPackage
))

# Log form events
$script:NewForm.Add_Shown({ Write-Log "Form shown" })
$script:NewForm.Add_FormClosing({ param($s,$e) Write-Log "Form closing: $($e.CloseReason)" })

Write-Log "Displaying form"
# Display the form
[void]$script:NewForm.ShowDialog()
Write-Log "Form dialog closed"
