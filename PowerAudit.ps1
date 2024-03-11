@"
 ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__|v0.6


"@

#-------------------------------------------- Progress-bar definition ---------------------------------------------

$TotalSteps = 12 

function Show-CustomProgressBar {
    param (
        [int]$CurrentStep,
        [int]$TotalSteps
    )
    
    $ProgressWidth = 50 
    $ProgressBar = [string]::Join('', ('o' * [math]::Round(($CurrentStep / $TotalSteps) * $ProgressWidth)))
    
    Write-Host -NoNewline "`r[$ProgressBar] $([math]::Round(($CurrentStep / $TotalSteps) * 12))/12 $stepName"

    if ($CurrentStep -eq $TotalSteps) {
        Write-Host ""  
    }
}

#----------------------------------------------- Folder creation ------------------------------------------------
$stepName = "Creating folders"
Show-CustomProgressBar -CurrentStep 1 -TotalSteps $TotalSteps

$appFolderName = "apps-list" #Defining the destination folder name
$outputFolderName = "output" #Defining the destination folder name

if (![System.IO.Directory]::Exists($outputFolderName)) {
    #If the folder does not exists

    New-Item $outputFolderName -ItemType Directory | Out-Null #Creating the output folder silently
    New-Item "$outputFolderName\$appFolderName" -ItemType Directory | Out-Null #Creating the app folder silently
} 

#---------------------------------------------- Hardware informations -----------------------------------------------
$stepName = "Getting hardware informations"
Show-CustomProgressBar -CurrentStep 2 -TotalSteps $TotalSteps

$systemInfo = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory, Domain, UserName # Obtain PC specs

$biosInfo = Get-CimInstance Win32_BIOS | Select-Object SerialNumber, SMBIOSBIOSVersion # Obtain the computer S/N and BIOS version

$processorInfo = Get-CimInstance Win32_Processor | Select-Object Name, MaxClockSpeed, NumberOfCores # Obtain CPU name, max clock speed, Number of cores

$gpuInfo = Get-CimInstance Win32_VideoController | Where-Object { ($_.Name -notlike '*virtual*') -and $_.DriverVersion -and $_.DriverDate } # Obtain GPU info

$ramInfo = Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Banklabel, DeviceLocator, Speed  # Obtain RAM info

#---------------------------------------------- Disks informations -----------------------------------------------
$stepName = "Getting disks informations"
Show-CustomProgressBar -CurrentStep 3 -TotalSteps $TotalSteps
 
$physicalDisksInfo = Get-PhysicalDisk | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB' } #Get the disk type and his RPM (if it's HDD)

$diskInfo = Get-Disk | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB' } #Get the disk informations(for health status)

$totalSpace = Get-Volume | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB' }  # Get the total volume ingoring USB, Removable and CD-ROM devices

#---------------------------------------------- System informations -----------------------------------------------
$stepName = "Getting system informations"
Show-CustomProgressBar -CurrentStep 4 -TotalSteps $TotalSteps

$osInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, CSName # Obtain OS informations

$initialInstallDate = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\' | Select-Object -ExpandProperty InstallDate # Obtain the initial OS install date in registery key

#---------------------------------------------- Network informations -----------------------------------------------
$stepName = "Getting network informations"
Show-CustomProgressBar -CurrentStep 5 -TotalSteps $TotalSteps

$networkConf = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled = TRUE" # Obtain infos about network cards that have an IP address

#---------------------------------------------- Printers informations -----------------------------------------------
$stepName = "Getting printers informations"
Show-CustomProgressBar -CurrentStep 6 -TotalSteps $TotalSteps

$printers = Get-CimInstance Win32_Printer | Where-Object { $_.Name -notlike '*OneNote*' -and $_.Name -notlike '*Microsoft*' } # Obtain all printers name except OneNote and Microsoft Printer

#---------------------------------------------- Listing programs -----------------------------------------------
$stepName = "Listing all programs"
Show-CustomProgressBar -CurrentStep 7 -TotalSteps $TotalSteps

$appsList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* # Registery key

#---------------------------------------------- Scan informations-----------------------------------------------
$stepName = "Generating scan informations"
Show-CustomProgressBar -CurrentStep 8 -TotalSteps $TotalSteps

$currentDate = Get-Date -Format "yyyy-MM-dd" # Obtain the date
$scanID = [Guid]::NewGuid().ToString("N").Substring(0, 8)  # Taking first 8 characters

#---------------------------------------------- Searching for Office app -----------------------------------------------

$stepName = "Searching for Office"
Show-CustomProgressBar -CurrentStep 9 -TotalSteps $TotalSteps

$office = ($appsList | Where-Object { ($_.DisplayName -like "*365*" -or $_.DisplayName -like "*Microsoft Office*") -and $_.Displayname -notlike "*Microsoft Teams*" } | Select-Object -ExpandProperty DisplayName) -replace '^Microsoft ', '' -replace ' -.*$', '' # $office take the app name found 

#---------------------------------------------- Checking if current user is admin -----------------------------------------------
$stepName = "Checking your role"
Show-CustomProgressBar -CurrentStep 10 -TotalSteps $TotalSteps

$administratorsGroupName = (New-Object Security.Principal.SecurityIdentifier("S-1-5-32-544")).Translate([Security.Principal.NTAccount]).Value # Identifying Administrator group by his SID (to prevent langage change)
$administratorsGroupName = $administratorsGroupName.Split('\')[-1] # Cut it before the backslash
$adminGroupMembers = net localgroup "$administratorsGroupName" # Checking all usernames in this admin group
$userName = $systemInfo.UserName.Split('\')[-1] # Cutting current username before the backslash

#------------------------------------------------- Creating global tab --------------------------------------------------
$stepName = "Generating tab"
Show-CustomProgressBar -CurrentStep 11 -TotalSteps $TotalSteps

$combinedData = [PSCustomObject]@{
    "Username"             = $userName
    "Administrator"        = if ($adminGroupMembers -match $userName) { "Yes" } else { "No" }
    "Model"                = $systemInfo.Model
    "Manufacturer"         = $systemInfo.Manufacturer
    "S/N"                  = $biosInfo.SerialNumber
    "BIOS Version"         = $biosInfo.SMBIOSBIOSVersion
    "Computer name"        = $osInfo.CSName
    "CPU"                  = $processorInfo.Name
    "Number of cores"      = $processorInfo.NumberOfCores
    "Frequency"            = ($processorInfo.MaxClockSpeed / 1000).ToString() + " GHz"
    "GPU"                  = ($gpuInfo | ForEach-Object { $_.Name }) -join ', '
    "GPU driver version"   = ($gpuInfo | ForEach-Object { $_.DriverVersion }) -join ', '
    "GPU Driver date"      = ($gpuInfo | ForEach-Object { $_.DriverDate.ToShortDateString() }) -join ', '
    "RAM manufacturer"     = ($ramInfo | ForEach-Object { $_.Manufacturer }) -join ', '
    "Total RAM amount"     = [math]::Ceiling([math]::Round($systemInfo.TotalPhysicalMemory / 1GB, 2)).ToString() + " GB"
    "RAM speed"            = ($ramInfo | ForEach-Object { $_.Speed.ToString() + " MHz" }) -join ', '
    "RAM Channel"          = ($ramInfo | ForEach-Object { $_.Banklabel }) -join ', '
    "RAM Slot"             = ($ramInfo | ForEach-Object { $_.DeviceLocator }) -join ','
    "Total disk space"     = [math]::Round(($totalSpace | Measure-Object -Property Size -Sum).Sum / 1GB, 2).ToString() + " GB"
    "Total free space"     = [math]::Round(($totalSpace | Measure-Object -Property SizeRemaining -Sum).Sum / 1GB, 2).ToString() + " GB" 
    "Disks type"           = ($physicalDisksInfo | ForEach-Object { $_.MediaType }) -join ', '
    "Disks model"          = ($physicalDisksInfo | ForEach-Object { $_.Model }) -join ', '
    "Disks health"         = ($diskInfo | ForEach-Object { $_.HealthStatus }) -join ', '
    "Disks partitions"     = ($diskInfo | ForEach-Object { $_.PartitionStyle }) -join ', '
    "OS"                   = $osInfo.Caption
    "Version"              = $osInfo.Version
    "Architecture"         = $osInfo.OSArchitecture
    "Domain"               = $systemInfo.Domain
    "IP Address"           = ($networkConf | ForEach-Object { $_.IPAddress }) -join ', '
    "Gateway"              = ($networkConf | ForEach-Object { $_.DefaultIPGateway }) -join ', '
    "DNS"                  = ($networkConf | ForEach-Object { $_.DNSServerSearchOrder }) -join ', '
    "DHCP"                 = ($networkConf | ForEach-Object { if ($_.DHCPEnabled) { "Yes" } else { "No" } }) -join ', '
    "Printers"             = ($printers | ForEach-Object { $_.Name }) -join ', '
    "Office Version"       = if ($office) { $office } else { "No" }
    "Initial install date" = ((Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($initialInstallDate))).ToString("yyyy-MM-dd")
    "Scan date"            = $currentDate
    "Scan ID"              = $scanID
}

#----------------------------------------------- Exporting all CSV files ------------------------------------------------
$stepName = "Exporting files"
Show-CustomProgressBar -CurrentStep 12 -TotalSteps $TotalSteps

$fileName = "results"
$fileName2 = $systemInfo.UserName.Split('\')[-1] + "-" + $scanID

Write-Host "Choose your output format"
Write-Host "1: CSV"
Write-Host "2: JSON"
$choice = Read-Host "Choice: "

if ($choice -eq "1") {
    $combinedData | Export-Csv -Path "$outputFolderName\$fileName.csv" -Delimiter ";" -Append -NoTypeinformation
    $appsList | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object { $_.DisplayName -ne $null } | Sort-Object DisplayName | Export-Csv -Path "$outputFolderName\$appFolderName\$fileName2.csv" -Delimiter ";" -Append -NoTypeinformation
}
elseif ($choice -eq "2") {
    $combinedData | ConvertTo-Json | out-File "$outputFolderName\$fileName.json"
    $appsList | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object { $_.DisplayName -ne $null } | Sort-Object DisplayName | ConvertTo-Json | Out-File  "$outputFolderName\$appFolderName\$fileName2.json"
}
else {
    Write-Host "Not valid."
}