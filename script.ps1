@"
 ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__|v0.4


"@
 

#-------------------------------------------- Warning messagebox ---------------------------------------------

Add-Type -AssemblyName PresentationFramework # load the assemply .NET framework (to make the script able to create a message box interface)
$caption = "Warning"
$messageBoxText = "This script will collect some hardware and software information (such as your components, your disk space and your OS version).`nIf you don't want this, you can cancel the execution.`nExecute anyway ?"
$caption = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($caption))
$text = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($messageBoxText))
$icon = [System.Windows.MessageBoxImage]::Information
$button = [System.Windows.MessageBoxButton]::OKCancel

$msgbox = [System.Windows.MessageBox]::Show($text, $caption, $button, $icon) # Mixing all components

if ($msgbox -eq "OK") {# If user clicked "OK"
    # User accepted
} else {
    # User declined, canceling the script
    exit
}

#-------------------------------------------- Progress-bar definition ---------------------------------------------

$TotalSteps = 4 

function Show-CustomProgressBar {
    param (
        [int]$CurrentStep,
        [int]$TotalSteps
    )
    
    $ProgressWidth = 50 
    $ProgressBar = [string]::Join('', ('|' * [math]::Round(($CurrentStep / $TotalSteps) * $ProgressWidth)))
    
    Write-Host -NoNewline "`r[$ProgressBar] $([math]::Round(($CurrentStep / $TotalSteps) * 4))/4 $stepName"

    if ($CurrentStep -eq $TotalSteps) {
        Write-Host ""  
    }
}

#Show-CustomProgressBar -CurrentStep <percentage> -TotalSteps $TotalSteps

#----------------------------------------------- Folder creation ------------------------------------------------
$stepName = "Creating folder"
Show-CustomProgressBar -CurrentStep 1 -TotalSteps $TotalSteps

$folderName = "apps-list" #Defining the destination folder name

if([System.IO.Directory]::Exists($folderName)) #If the folder exists
{
 #Folder exists :shocked_face:
}
else{ #Else
    New-Item $folderName -ItemType Directory | Out-Null #Creating the folder silently
}

#---------------------------------------------- Defining objects -----------------------------------------------

$stepName = "Defining objects"
Show-CustomProgressBar -CurrentStep 2 -TotalSteps $TotalSteps

$systemInfo = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory, Domain, UserName # Obtain PC specs

$biosInfo = Get-CimInstance Win32_BIOS | Select-Object SerialNumber, SMBIOSBIOSVersion # Obtain the computer S/N and BIOS version

$processorInfo = Get-CimInstance Win32_Processor | Select-Object Name, MaxClockSpeed, NumberOfCores # Obtain CPU name, max clock speed, Number of cores

$gpuInfo = Get-CimInstance Win32_VideoController | Where-Object { $_.Name -and $_.DriverVersion -and $_.DriverDate} # Obtain GPU info
 
$physicalDisksInfo = Get-PhysicalDisk | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB'} #Get the disk type and his RPM (if it's HDD)

$diskInfo = Get-Disk | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB'} #Get the disk informations(for health status)

$totalSpace = Get-Volume | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB'}  # Get the total volume ingoring USB, Removable and CD-ROM devices

$osInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, CSName # Obtain OS informations

$encryptionStatus = manage-bde -status C: | Out-String #Check if your computer is encrypted by BitLocker

$currentDate = Get-Date -Format "yyyy-MM-dd" # Obtain the date

$initialInstallDate = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\' | Select-Object -ExpandProperty InstallDate # Obtain the initial OS install date in registery key

$appsList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* # Registery key

#------------------------------------------------- Creating global tab --------------------------------------------------

$stepName = "Generating tab"
Show-CustomProgressBar -CurrentStep 3 -TotalSteps $TotalSteps

$combinedData = [PSCustomObject]@{
    "Username" = $systemInfo.UserName.Split('\')[-1]
    "Model" = $systemInfo.Model
    "Manufacturer" = $systemInfo.Manufacturer
    "S/N" = $biosInfo.SerialNumber
    "BIOS Version" = $biosInfo.SMBIOSBIOSVersion
    "Computer name" = $osInfo.CSName
    "CPU" = $processorInfo.Name
    "Number of cores" = $processorInfo.NumberOfCores
    "Frequency" = ($processorInfo.MaxClockSpeed /1000).ToString() + " GHz"
    "GPU" = ($gpuInfo | ForEach-Object {$_.Name}) -join ', '
    "GPU driver version" = ($gpuInfo | ForEach-Object {$_.DriverVersion}) -join ', '
    "GPU Driver date" = ($gpuInfo | ForEach-Object {$_.DriverDate.ToShortDateString()}) -join ', '
    "RAM" = [math]::Ceiling([math]::Round($systemInfo.TotalPhysicalMemory / 1GB, 2)).ToString() + " GB"
    "Total disk space" = [math]::Round(($totalSpace | Measure-Object -Property Size -Sum).Sum / 1GB, 2).ToString() + " GB"
    "Total free space" = [math]::Round(($totalSpace | Measure-Object -Property SizeRemaining -Sum).Sum / 1GB, 2).ToString() + " GB" 
    "Disks type" = ($physicalDisksInfo | ForEach-Object { $_.MediaType}) -join ', '
    "Disks model" = ($physicalDisksInfo | ForEach-Object { $_.Model}) -join ', '
    "Disks health" = ($diskInfo| ForEach-Object { $_.HealthStatus}) -join ', '
    "Disks partitions" = ($diskInfo| ForEach-Object { $_.PartitionStyle}) -join ', '
    "OS" = $osInfo.Caption
    "Version" = $osInfo.Version
    "Architecture" = $osInfo.OSArchitecture
    "Domain" = $systemInfo.Domain
#   "Specific software" = $appsList | Where-Object { $_.DisplayName -like "* YourSoftwareName *" } | Select-Object -ExpandProperty DisplayVersion -First 1 # Searching for a specific software version
    "BitLocker encryption" = if ($encryptionStatus -match "Protection On") { "Yes" } else { "No" }
    "Initial install date" = ((Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($initialInstallDate))).ToString("yyyy-MM-dd")
    "Scan date" = $currentDate
}

#----------------------------------------------- Exporting all CSV files ------------------------------------------------

$stepName = "Exporting files"
Show-CustomProgressBar -CurrentStep 4 -TotalSteps $TotalSteps

$fileName = "results.csv"
$fileName2 = $systemInfo.UserName.Split('\')[-1] + "-" + $osInfo.CSName + ".csv"

$combinedData | Export-Csv -Path $fileName -Delimiter ";" -Append -NoTypeInformation
$appsList | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object { $_.DisplayName -ne $null } | Sort-Object DisplayName | Export-Csv -Path "$folderName\$fileName2" -Delimiter ";" -Append -NoTypeInformation