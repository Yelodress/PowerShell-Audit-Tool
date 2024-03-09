# Documentation

### ⚠️ Please note that this script is modular. Some parameters are in comments. Uncomment them to use them.

## UFT-8 conversion
If you're facing an issue with special characters in your custom text, consider converting them to UTF-8:
```PowerShell
$yourVarName = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes("Your text"))
```

## Adding a step to the progress-bar
### Adding a step:
```PowerShell
$stepName = "Your Step"
Show-CustomProgressBar -CurrentStep X -TotalSteps $TotalSteps
```
(do not forget to replace X by your step number)

### Progress-bar settings to modify
Replace every X by your total amount of step
```PowerShell
$TotalSteps = X 

function Show-CustomProgressBar {
    param (
        [int]$CurrentStep,
        [int]$TotalSteps
    )
    
    $ProgressWidth = 50 
    $ProgressBar = [string]::Join('', ('o' * [math]::Round(($CurrentStep / $TotalSteps) * $ProgressWidth)))
    
    Write-Host -NoNewline "`r[$ProgressBar] $([math]::Round(($CurrentStep / $TotalSteps) * X))/X $stepName"

    if ($CurrentStep -eq $TotalSteps) {
        Write-Host ""  
    }
}
```

## Searching for a specific user/group
### Specific useror group
Add this as a new column in `$combinedData`:
```PowerShell
"Specific user" = if (Get-LocalUser -Name "Your username") {"Yes"} else {"No"}
```
```PowerShell
"Specific group" = if (Get-LocalGroup -Name "Your group name") {"Yes"} else {"No"}
```

## Finding a specific software
Add this as a new column in `$combinedData`
```PowerShell
"Specific software" = $appsList | Where-Object { $_.DisplayName -like "* Your software name *" } | Select-Object -ExpandProperty DisplayVersion -First 1
```
**Note:** You can remove the asterisks if you're sure of your exact app name.

## Warning messagebox
You can add a messagebox to warn users from what informations you're going to retrieve.
Add this on the top of your script:
```PowerShell
Add-Type -AssemblyName PresentationFramework # load the assembly .NET framework (to make the script able to create a message box interface)
$caption = "Title"
$messageBoxText = "Description"
$icon = [System.Windows.MessageBoxImage]::Information
$button = [System.Windows.MessageBoxButton]::OKCancel

$msgbox = [System.Windows.MessageBox]::Show($messageBoxText, $caption, $button, $icon) # Mixing all components

if ($msgbox -eq "OK") {
    # User accepted, coninue
}
else {
    # User declined, canceling the script
    exit
}
```