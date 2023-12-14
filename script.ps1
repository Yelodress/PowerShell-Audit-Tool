@"
 ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__|v0.1 patch 2
"@
 
 Add-Type -AssemblyName PresentationFramework

# Messagebox components definition
$messageBoxText = "This script will collect some hardware and software information (such as your components, your disk space and your OS version).`nIf you don't want this, you can cancel the execution.`nExecute anyway ?"
$caption = "Warning"
$button = [System.Windows.MessageBoxButton]::OKCancel
$icon = [System.Windows.MessageBoxImage]::Information
$bytes = [System.Text.Encoding]::Default.GetBytes($messageBoxText)
$textUtf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
$bytes = [System.Text.Encoding]::Default.GetBytes($caption)
$captionUtf8 = [System.Text.Encoding]::UTF8.GetString($bytes)

$result = [System.Windows.MessageBox]::Show($textUtf8, $captionUtf8, $button, $icon) # Mixing all components

if ($result -eq "OK") {# If user clicked "OK"
    # User accepted
} else {
    # User declined, canceling the script
    exit
}

$folderName = "Client-apps" #Defining the destination folder name

if([System.IO.Directory]::Exists($folderName)) #If the folder exists
{
 #Folder exists :shocked_face:
}
else{ #Else
    New-Item $folderName -ItemType Directory #Creating the folder 
}

#Getting the full installed software list
$appsList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*,
                                  HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
                  Select-Object DisplayName, DisplayVersion, Publisher |
                  Where-Object { $_.DisplayName -ne $null } |
                  Sort-Object DisplayName

$userName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name.Split('\')[-1]
 
$fileName = "results.csv"
$fileName2 = "Applications-" + $userName + ".csv"
 

$totalSpace = Get-Volume # Obtain the total disk space

$totalFreeSpace = Get-Volume | Where-Object { $_.DriveType -ne 'Removable' } # Ingore removable devices
$totalFreeSpace2 = ($totalFreeSpace | Measure-Object -Property SizeRemaining -Sum).Sum / 1GB # Measure the free space
$totalFreeSpaceGo = [math]::Round($totalFreeSpace2, 2) # Divide the free space (in MB) to get in in GB

$systemInfo = Get-CimInstance Win32_ComputerSystem | Select-Object Manufacturer, Model, TotalPhysicalMemory # Obtain PC specs
 
$processorInfo = Get-CimInstance Win32_Processor | Select-Object Name # Obtain CPU model

$cpuFrequency = (Get-WmiObject -Class Win32_Processor).MaxClockSpeed # Obtain CPU max frequency in Hz
$cpuFrequencyGHz = $cpuFrequency / 1000 # Converting Hz to GHz
 
$gpuInfo = Get-CimInstance Win32_VideoController | Select-Object Name # Obtain GPU model

#currentDate = Get-Date -Format "yyyy-MM-dd" # Obtain the date

$computerName = $env:COMPUTERNAME # Obtain the PC name

$domainName = (Get-WmiObject Win32_ComputerSystem).Domain # Obtain the domain name of your network

$encryptionStatus = manage-bde -status C: | Out-String #Check if your computer is encrypted by BitLocker
$isEncrypted = if ($encryptionStatus -match "Protection On") { "Yes" } else { "No" } # Write "Yes" or "No"

#$specificSoftware = "Your Sofware Name" # Define the software to research
#$softwareVersion = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, # Checking the \Uninstall folder
#                                   HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
#                   Where-Object { $_.DisplayName -like "*$specificSoftware*" } | # Searching for your software
#                   Select-Object -ExpandProperty DisplayVersion -First 1 # Get the sofware version





#Sore information in objets:
$systemManufacturer = $systemInfo.Manufacturer
$systemModel = $systemInfo.Model
$osInfo = Get-CimInstance Win32_OperatingSystem | Select-Object Caption, Version, OSArchitecture
$processorName = ($processorInfo | Select-Object -ExpandProperty Name)
$systemMemory = [math]::Round($systemInfo.TotalPhysicalMemory / 1GB, 2)
$systemMemoryGB = "$systemMemory GB"
$totalSpace = Get-Volume | Where-Object { $_.DriveType -ne 'Removable' }
$espaceTotal2 = ($totalSpace | Measure-Object -Property Size -Sum).Sum / 1GB
$espaceTotalGo = [math]::Round($espaceTotal2, 2)
$gpuName = ($gpuInfo | Select-Object -ExpandProperty Name)

 
# Creating a global object
$combinedData = [PSCustomObject]@{
    "Username" = $userName
    "Model" = $systemModel
    "Manufacturer" = $systemManufacturer
    "Computer name" = $computerName
    "CPU" = $processorName
    "Frequency" = "$cpuFrequencyGHz GHz"
    "GPU" = $gpuName
    "RAM" = $systemMemoryGB
    "Total disk space" = "$espaceTotalGo GB"
    "Total free space" = "$totalFreeSpaceGo GB"
    "OS" = $osInfo.Caption
#    "Version" = $osInfo.Version
    "Architecture" = $osInfo.OSArchitecture
    "Domain" = $domainName
#    "Specific software" = $softwareVersion
    "Encryption" = $isEncrypted
#    "Date" = $currentDate
}


# Export all data in CSV files
$combinedData | Export-Csv -Path $fileName -Delimiter ";" -Append -NoTypeInformation
$appsList | Export-Csv -Path "$folderName\$fileName2" -Delimiter ";" -Append -NoTypeInformation

