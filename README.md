# PowerAudit v0.4 IS HERE !
## Let's take a look at this update:

### What's been added ?
  - Added the disk health status
  - Added the initial Windows install date
  - Added the disk partition type
  - Added the progress bar (finally !)

### What's been fixed ?  
  - The Microsoft Office app search works now `(v0.4.1)`

### Miscellaneous  
  - Removed some useless function calls
  - Various optimization
  - Removed useless calls for the Message Box
  - $specificSoftware is now called once
  - Improved the way $applist locate installed programs by adding a third path
  - Reworked the way out files are named


## PowerAudit roadmap:
- The ability to choose the folder's name (maybe in a textbox)
- A parallel script (not in PowerShell) if you're running it under Win 8.1
- ...

### Features improvement roadmap:
- ...

I'm open to all suggestions :)

If youre facing issues with this script, tell me [here](https://github.com/Yelodress/PowerShell-Audit-Tool/issues)
 
# Documentation

### Please note that this script is modular. Some parameters are in comments. Uncomment them to use them.

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
