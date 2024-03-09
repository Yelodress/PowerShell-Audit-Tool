<div align="center">
<h1>PowerAudit</h1>
<img alt="Static Badge" src="https://img.shields.io/badge/windows_version-8.1_%7C_10_%7C_11-green?style=for-the-badge&logo=windows&labelColor=%23313244&color=%2389dceb" style="margin-right: 10px">
<img alt="Static Badge" src="https://img.shields.io/badge/Release-v0.5-green?style=for-the-badge&labelColor=%23313244&color=%23a6e3a1" style="margin-right: 10px">
<h3>
an open source powershell script for retrieving Windows computers specifications and storing them in CSV files.
</h3>
</div>

## 📋 Features

- ⚡ Extremely fast
- 👍 Really Simple - one single script
- 🔧 Modular
- 🍃 Lightweight

## 📓 Documentation
As a modular script, you can see all unused functions in the [documentation](https://github.com/spartanfant0me/PowerShell-Audit-Tool/wiki/Documentation).

## 📁 Ouput
<pre>
├── PowerAudit.exe / script.ps1
└── output
    ├── result.csv - contain computer specific informations
    └── apps-list
        ├── user-id.csv - contain user installed software's 
        ├── user-id.csv - contain user installed software's
        └── user-id.csv - contain user installed software's
</pre>

## 🚧 Roadmap:
- adding the ability to choose the folder's name (maybe in a textbox)
- adding the ability to choose the output format (maybe in a textbox)


I'm open to all suggestions :)

If you're facing issues with this script, tell me [here](https://github.com/Yelodress/PowerShell-Audit-Tool/issues).

## Collected data 
### Hardware
- <img src="https://api.iconify.design/bi:motherboard-fill.svg" height="15" style="filter: invert()"> Motherboard model
- <img src="https://api.iconify.design/bi:motherboard-fill.svg" height="15" style="filter: invert()"> Motherboard serial number
- <img src="https://api.iconify.design/bi:motherboard-fill.svg" height="15" style="filter: invert()"> Motherboard BIOS version
- <img src="https://api.iconify.design/ri:cpu-line.svg" height="15" style="filter: invert()"> Computer's architecture
- <img src="https://api.iconify.design/ri:cpu-line.svg" height="15" style="filter: invert()"> CPU model
- <img src="https://api.iconify.design/ri:cpu-line.svg" height="15" style="filter: invert()"> CPU cores
- <img src="https://api.iconify.design/ri:cpu-line.svg" height="15" style="filter: invert()"> CPU frequency
- <img src="https://api.iconify.design/bi:gpu-card.svg" height="15" style="filter: invert()"> GPU model
- <img src="https://api.iconify.design/bi:gpu-card.svg" height="15" style="filter: invert()"> GPU Drivers version
- <img src="https://api.iconify.design/bi:gpu-card.svg" height="15" style="filter: invert()"> GPU drivers release date
- <img src="https://api.iconify.design/clarity:memory-solid.svg" height="15" style="filter: invert()"> RAM amount
- <img src="https://api.iconify.design/mdi:harddisk.svg" height="15" style="filter: invert()"> Total Disk space
- <img src="https://api.iconify.design/mdi:harddisk.svg" height="15" style="filter: invert()"> Total Free space
- <img src="https://api.iconify.design/mdi:harddisk.svg" height="15" style="filter: invert()"> Disks types
- <img src="https://api.iconify.design/mdi:harddisk.svg" height="15" style="filter: invert()"> Disks models
- <img src="https://api.iconify.design/mdi:harddisk.svg" height="15" style="filter: invert()"> Disk health status
- <img src="https://api.iconify.design/mdi:harddisk.svg" height="15" style="filter: invert()"> Disk partition type
### Sofware
- <img src="https://api.iconify.design/mdi:account.svg" height="15" style="filter: invert()"> Username
- <img src="https://api.iconify.design/material-symbols:admin-panel-settings.svg" height="15" style="filter: invert()"> User administrator status
- <img src="https://api.iconify.design/ph:computer-tower-fill.svg" height="15" style="filter: invert()"> Computer's hostname
- <img src="https://api.iconify.design/mdi:microsoft-windows.svg" height="15" style="filter: invert()"> Windows version
- <img src="https://api.iconify.design/material-symbols:domain.svg" height="15" style="filter: invert()"> Domain
- <img src="https://api.iconify.design/mdi:ip-network.svg" height="15" style="filter: invert()"> IP address
- <img src="https://api.iconify.design/material-symbols:router.svg" height="15" style="filter: invert()"> Gateway
- <img src="https://api.iconify.design/material-symbols:dns.svg" height="15" style="filter: invert()"> DNS
- <img src="https://api.iconify.design/mdi:server.svg" height="15" style="filter: invert()"> DHCP status
- <img src="https://api.iconify.design/material-symbols:lock.svg" height="15" style="filter: invert()"> Bitlocker status
- <img src="https://api.iconify.design/mdi:microsoft-office.svg" height="15" style="filter: invert()"> office installed version
- <img src="https://api.iconify.design/material-symbols:calendar-month.svg" height="15" style="filter: invert()"> Windows installation date
### Apps
- <img src="https://api.iconify.design/mdi:file.svg" height="15" style="filter: invert()"> Name
- <img src="https://api.iconify.design/mdi:file-arrow-left-right.svg" height="15" style="filter: invert()"> Version
- <img src="https://api.iconify.design/mdi:file-account.svg" height="15" style="filter: invert()"> Publisher