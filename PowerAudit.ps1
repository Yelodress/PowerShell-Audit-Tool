@"
 ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__|v0.7.2


"@

#-------------------------------------------- Progress-bar definition ---------------------------------------------

$TotalSteps = 15 

function Show-CustomProgressBar {
    param(
        [int]$CurrentStep,
        [int]$TotalSteps,
        [string]$StepName
    )
    $ProgressWidth = 50
    $Progress = "o" * ($CurrentStep * $ProgressWidth / $TotalSteps)
    Write-Host "`r[$Progress".PadRight($ProgressWidth) "] $CurrentStep/15 $StepName           " -NoNewline
    if ($CurrentStep -eq $TotalSteps) {
        Write-Host ""
    }
}

#----------------------------------------------- Folder creation ------------------------------------------------
$stepName = "Creating folders"
Show-CustomProgressBar -CurrentStep 1 -TotalSteps $TotalSteps $stepName

#Defining destination folder names
$appFolderName = "apps-list"
$outputFolderName = "output"

if (![System.IO.Directory]::Exists($outputFolderName)) {
    #If the folder does not exists

    New-Item $outputFolderName -ItemType Directory | Out-Null #Creating the output folder silently
    New-Item "$outputFolderName\$appFolderName" -ItemType Directory | Out-Null #Creating the app folder silently
} 

#---------------------------------------------- Hardware informations -----------------------------------------------
$stepName = "Getting hardware informations"
Show-CustomProgressBar -CurrentStep 2 -TotalSteps $TotalSteps $stepName

$systemInfo = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory, Domain, UserName # Obtain PC specs

$biosInfo = Get-CimInstance Win32_BIOS | Select-Object SerialNumber, SMBIOSBIOSVersion # Obtain the computer S/N and BIOS version

$processorInfo = Get-CimInstance Win32_Processor | Select-Object Name, MaxClockSpeed, NumberOfCores, L2CacheSize, L3CacheSize, ThreadCount, AddressWidth, SocketDesignation, VirtualizationFirmwareEnabled # Obtain CPU name, max clock speed, Number of cores

$gpuInfo = Get-CimInstance Win32_VideoController | Where-Object { ($_.Name -notlike '*virtual*') -and $_.DriverVersion -and $_.DriverDate } # Obtain GPU driver info

$gpuVRAM = [math]::round((Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0*" -Name HardwareInformation.qwMemorySize -ErrorAction SilentlyContinue)."HardwareInformation.qwMemorySize"/1GB)

$ramInfo = Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, Banklabel, DeviceLocator, Speed  # Obtain RAM info

$batteryInfo = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue | Select-Object Status  # Obtain the battery health status

#---------------------------------------------- Disks informations -----------------------------------------------
$stepName = "Getting disks informations"
Show-CustomProgressBar -CurrentStep 3 -TotalSteps $TotalSteps $stepName
 
$physicalDisksInfo = Get-PhysicalDisk | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB' } #Get the disk type and his RPM (if it's HDD)

$diskInfo = Get-Disk | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB' } #Get the disk informations(for health status)

$totalSpace = Get-Volume | Where-Object { $_.DriveType -ne 'Removable' -and $_.DriveType -ne 'CD-ROM' -and $_.BusType -ne 'USB' }  # Get the total volume ingoring USB, Removable and CD-ROM devices

$diskID = Get-CimInstance Win32_LogicalDisk | Where-Object { $_.ProviderName -notlike '*\\*'}| Select-Object DeviceID # Get the disk letter

#------------------------------------------------- Network drive --------------------------------------------------
$stepName = "Retrieving network drives"
Show-CustomProgressBar -CurrentStep 4 -TotalSteps $TotalSteps $stepName

$networkDrive = Get-CimInstance Win32_NetworkConnection

#---------------------------------------------- System informations -----------------------------------------------
$stepName = "Getting system informations"
Show-CustomProgressBar -CurrentStep 5 -TotalSteps $TotalSteps $stepName

$osInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture, CSName # Obtain OS informations

$initialInstallDate = Get-ItemProperty 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\' | Select-Object -ExpandProperty InstallDate # Obtain the initial OS install date in registery key

#---------------------------------------------- Network informations -----------------------------------------------
$stepName = "Getting network informations"
Show-CustomProgressBar -CurrentStep 6 -TotalSteps $TotalSteps $stepName

$networkConf = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object {$_.Caption -notlike "*virtual*" -and $_.Caption -notlike "*WAN*"  -and $_.Caption -notlike "*bluetooth*" -and $_.MACAddress -ne $null} # Obtain infos about network cards that have an IP address

#---------------------------------------------- Printers informations -----------------------------------------------
$stepName = "Getting printers informations"
Show-CustomProgressBar -CurrentStep 7 -TotalSteps $TotalSteps $stepName

$printers = Get-CimInstance Win32_Printer | Where-Object { $_.Name -notlike '*OneNote*' -and $_.Name -notlike '*Microsoft*' } # Obtain all printers name except OneNote and Microsoft Printer

#---------------------------------------------- Bitlocker encryption check -----------------------------------------------
$stepName = "Checking bitlocker encryption"
Show-CustomProgressBar -CurrentStep 8 -TotalSteps $TotalSteps $stepName
function valueCompare ($isEncrypted) {

    if ($isEncrypted -eq 2) {
        return "Not encrypted"
    } elseif ($isEncrypted -eq 1) {
        return "Encrypted"
    } elseif ($isEncrypted -eq 3) {
        return "Encryption in progress"
    } elseif ($isEncrypted -eq 0) {
        return "Unencryptable"
    }
    return "Unknown"
}

$isEncrypted = @()

foreach($letter in $diskID){
    $getStatus = valueCompare(((New-Object -ComObject Shell.Application).NameSpace($letter.DeviceID).Self.ExtendedProperty('System.Volume.BitLockerProtection')))
    $status = $letter.DeviceID + ' ' + $getStatus
    $isEncrypted += $status
}

#---------------------------------------------- Listing programs -----------------------------------------------
$stepName = "Listing all programs"
Show-CustomProgressBar -CurrentStep 9 -TotalSteps $TotalSteps $stepName

$appsList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* # Registery key

#---------------------------------------------- Scan informations-----------------------------------------------
$stepName = "Generating scan informations"
Show-CustomProgressBar -CurrentStep 10 -TotalSteps $TotalSteps $stepName

$currentDate = Get-Date -Format "yyyy-MM-dd" # Obtain the date
$scanID = [Guid]::NewGuid().ToString("N").Substring(0, 8)  # Taking first 8 characters

#---------------------------------------------- Searching for Office app -----------------------------------------------

$stepName = "Searching for Office"
Show-CustomProgressBar -CurrentStep 11 -TotalSteps $TotalSteps $stepName

$office = ($appsList | Where-Object { $_.DisplayName -like "*365*" -or $_.DisplayName -like "*Microsoft Office Standard*" -or $_.DisplayName -like "*Microsoft Office Pro*" -or $_.DisplayName -like "*Microsoft Office Fam*" -or $_.DisplayName -like "*Microsoft Office Ent*" -or $_.DisplayName -like "*Microsoft Office Home*" } -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName -First 1) -replace '^Microsoft ', '' -replace ' -.*$' # $office take the app name found 

#---------------------------------------------- Checking if current user is admin -----------------------------------------------
$stepName = "Checking your role"
Show-CustomProgressBar -CurrentStep 12 -TotalSteps $TotalSteps $stepName

$administratorsGroupName = (New-Object Security.Principal.SecurityIdentifier("S-1-5-32-544")).Translate([Security.Principal.NTAccount]).Value # Identifying Administrator group by his SID (to prevent langage change)
$administratorsGroupName = $administratorsGroupName.Split('\')[-1] # Cut it before the backslash
$adminGroupMembers = net localgroup "$administratorsGroupName" # Checking all usernames in this admin group
$userName = $systemInfo.UserName.Split('\')[-1] # Cutting current username before the backslash

#------------------------------------------------- Getting antivirus --------------------------------------------------
$stepName = "Checking your antivirus"
Show-CustomProgressBar -CurrentStep 13 -TotalSteps $TotalSteps $stepName

$antivirus = Get-CimInstance -Namespace "ROOT\SecurityCenter2" -ClassName AntivirusProduct 

#------------------------------------------------- Creating global tab --------------------------------------------------
$stepName = "Generating tab"
Show-CustomProgressBar -CurrentStep 14 -TotalSteps $TotalSteps $stepName

$combinedData = [PSCustomObject]@{
    "Username"             = $userName
    "Administrator"        = if ($adminGroupMembers -match $userName) { "Yes" } else { "No" }
    "Computer Model"       = $systemInfo.Model
    "Computer Manufacturer"= $systemInfo.Manufacturer
    "Computer S/N"         = $biosInfo.SerialNumber
    "Computer Name"        = $osInfo.CSName
    "BIOS Version"         = $biosInfo.SMBIOSBIOSVersion
    "CPU"                  = $processorInfo.Name
    "CPU Cores"            = $processorInfo.NumberOfCores
    "CPU Threads"          = $processorInfo.ThreadCount
    "CPU Frequency"        = ($processorInfo.MaxClockSpeed / 1000).ToString() + " GHz"
    "CPU L2 Cache Size"    = [math]::Round($processorInfo.L2CacheSize /1024, 1).ToString() + " MB"
    "CPU L3 Cache Size"    = [math]::Round($processorInfo.L3CacheSize /1024, 1).ToString() + " MB"
    "CPU Architecture"     = $processorInfo.AddressWidth.ToString() + " bits"
    "CPU Socket"           = $processorInfo.SocketDesignation
    "CPU Virtualization"   = if($processorInfo.VirtualizationFirmwareEnabled -match "True") {"On"} else {"Off"}
    "GPU"                  = ($gpuInfo | ForEach-Object { $_.Name }) -join ', '
    "GPU VRAM"             = ($gpuVRAM.ToString() + " GB") -join ', '
    "GPU Driver Version"   = ($gpuInfo | ForEach-Object { $_.DriverVersion }) -join ', '
    "GPU Driver Date"      = ($gpuInfo | ForEach-Object { $_.DriverDate.ToShortDateString() }) -join ', '
    "RAM Manufacturer"     = ($ramInfo | ForEach-Object { $_.Manufacturer }) -join ', '
    "Total RAM Amount"     = [math]::Ceiling([math]::Round($systemInfo.TotalPhysicalMemory / 1GB, 2)).ToString() + " GB"
    "RAM Frequency"        = ($ramInfo | ForEach-Object { $_.Speed.ToString() + " MHz" }) -join ', '
    "RAM Channel"          = ($ramInfo | ForEach-Object { $_.Banklabel }) -join ', '
    "RAM Slot"             = ($ramInfo | ForEach-Object { $_.DeviceLocator }) -join ','
    "Total Disk Space"     = [math]::Round(($totalSpace | Measure-Object -Property Size -Sum).Sum / 1GB, 2).ToString() + " GB"
    "Total Free Space"     = [math]::Round(($totalSpace | Measure-Object -Property SizeRemaining -Sum).Sum / 1GB, 2).ToString() + " GB" 
    "Disks Type"           = ($physicalDisksInfo | ForEach-Object { $_.MediaType }) -join ', '
    "Disks Model"          = ($physicalDisksInfo | ForEach-Object { $_.Model }) -join ', '
    "Disks Health"         = ($diskInfo | ForEach-Object { $_.HealthStatus }) -join ', '
    "Disks Partitions"     = ($diskInfo | ForEach-Object { $_.PartitionStyle }) -join ', '
    "Network Drives"       = ($networkDrive | ForEach-Object { $_.LocalName + $_.RemoteName }) -join ', '
    "Battery Health"       = if ($batteryInfo.Status) {$batteryInfo.Status} else {"None"}
    "OS"                   = $osInfo.Caption
    "OS Version"           = $osInfo.Version
    "OS Architecture"      = $osInfo.OSArchitecture
    "Domain"               = $systemInfo.Domain
    "IP Address"           = ($networkConf | ForEach-Object { $_.IPAddress }) -join ', '
    "MAC Address"          = ($networkConf | ForEach-Object { $_.MACAddress }) -join ', '
    "Gateway"              = ($networkConf | ForEach-Object { $_.DefaultIPGateway }) -join ', '
    "DNS"                  = ($networkConf | ForEach-Object { $_.DNSServerSearchOrder }) -join ', '
    "DHCP"                 = ($networkConf | ForEach-Object { if ($_.DHCPEnabled) { "Yes" } else { "No" } }) -join ', '
    "Printers"             = ($printers | ForEach-Object { $_.Name }) -join ', '
    "Bitlocker Encryption" = (ForEach-Object {$isEncrypted}) -join ', '
    "Active Antivirus"     = ($antivirus | Where-Object { $_.productState -notlike '*393*' -and $_.productState -notlike '0' } |ForEach-Object {$_.DisplayName}) -join ', '
    "Other Antivirus"      = ($antivirus | Where-Object { $_.productState -notlike '*266*' } |ForEach-Object {$_.DisplayName}) -join ', '
    "Office Version"       = if ($office) { $office -join ', '} else { "No" }
    "System Install Date"  = ((Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($initialInstallDate))).ToString("yyyy-MM-dd")
    "Scan Date"            = $currentDate
    "Scan ID"              = $scanID
}

#----------------------------------------------- Exporting all CSV files ------------------------------------------------
$stepName = "Exporting files"
Show-CustomProgressBar -CurrentStep 15 -TotalSteps $TotalSteps $stepName

$fileName = "results"
$fileName2 = $systemInfo.UserName.Split('\')[-1] + "-" + $scanID

function conversion ($choice){
    Write-Host "Choose your output format"
    Write-Host "1: CSV"
    Write-Host "2: JSON"
    $choice = Read-Host "Choice: "  

    if ($choice -eq 1) {
        $combinedData | Export-Csv -Path "$outputFolderName\results.csv" -Delimiter ";" -Append -NoTypeinformation
        $appsList | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object { $null -ne $_.DisplayName } | Sort-Object DisplayName | Export-Csv -Path "$outputFolderName\$appFolderName\$fileName2.csv" -Delimiter ";" -NoTypeinformation
    }
    elseif ($choice -eq 2) {
        $combinedData | ConvertTo-Json | out-File "$outputFolderName\results-$scanID.json"
        $appsList | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object { $null -ne $_.DisplayName } | Sort-Object DisplayName | ConvertTo-Json | Out-File  "$outputFolderName\$appFolderName\$fileName2.json"
    }
    else {
        Write-Host "Not valid."
        conversion
    }
}

conversion