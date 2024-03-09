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
- <img src="https://api.iconify.design/bi:motherboard-fill.svg?color=%23cdd6f4" height="15" alt=""> Motherboard model
- <img src="https://api.iconify.design/bi:motherboard-fill.svg?color=%23cdd6f4" height="15" alt=""> Motherboard serial number
- <img src="https://api.iconify.design/bi:motherboard-fill.svg?color=%23cdd6f4" height="15" alt=""> Motherboard BIOS version
- <img src="https://api.iconify.design/ri:cpu-line.svg?color=%23cdd6f4" height="15" alt=""> Computer's architecture
- <img src="https://api.iconify.design/ri:cpu-line.svg?color=%23cdd6f4" height="15" alt=""> CPU model
- <img src="https://api.iconify.design/ri:cpu-line.svg?color=%23cdd6f4" height="15" alt=""> CPU cores
- <img src="https://api.iconify.design/ri:cpu-line.svg?color=%23cdd6f4" height="15" alt=""> CPU frequency
- <img src="https://api.iconify.design/bi:gpu-card.svg?color=%23cdd6f4" height="15" alt=""> GPU model
- <img src="https://api.iconify.design/bi:gpu-card.svg?color=%23cdd6f4" height="15" alt=""> GPU Drivers version
- <img src="https://api.iconify.design/bi:gpu-card.svg?color=%23cdd6f4" height="15"  alt=""> GPU drivers release date
- <img src="https://api.iconify.design/clarity:memory-solid.svg?color=%23cdd6f4" height="15"  alt=""> RAM amount
- <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Total Disk space
- <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Total Free space
- <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Disks types
- <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Disks models
- <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Disk health status
- <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Disk partition type
### Sofware
- <img src="https://api.iconify.design/mdi:account.svg?color=%23cdd6f4" height="15"  alt=""> Username
- <img src="https://api.iconify.design/material-symbols:admin-panel-settings.svg?color=%23cdd6f4" height="15"  alt=""> User administrator status
- <img src="https://api.iconify.design/ph:computer-tower-fill.svg?color=%23cdd6f4" height="15"  alt=""> Computer's hostname
- <img src="https://api.iconify.design/mdi:microsoft-windows.svg?color=%23cdd6f4" height="15"  alt=""> Windows version
- <img src="https://api.iconify.design/material-symbols:domain.svg?color=%23cdd6f4" height="15"  alt=""> Domain
- <img src="https://api.iconify.design/mdi:ip-network.svg?color=%23cdd6f4" height="15"  alt=""> IP address
- <img src="https://api.iconify.design/material-symbols:router.svg?color=%23cdd6f4" height="15"  alt=""> Gateway
- <img src="https://api.iconify.design/material-symbols:dns.svg?color=%23cdd6f4" height="15"  alt=""> DNS
- <img src="https://api.iconify.design/mdi:server.svg?color=%23cdd6f4" height="15"  alt=""> DHCP status
- <img src="https://api.iconify.design/material-symbols:lock.svg?color=%23cdd6f4" height="15"  alt=""> Bitlocker status
- <img src="https://api.iconify.design/mdi:microsoft-office.svg?color=%23cdd6f4" height="15"  alt=""> office installed version
- <img src="https://api.iconify.design/material-symbols:calendar-month.svg?color=%23cdd6f4" height="15"  alt=""> Windows installation date
### Apps
- <img src="https://api.iconify.design/mdi:file.svg?color=%23cdd6f4" height="15"  alt=""> Name
- <img src="https://api.iconify.design/mdi:file-arrow-left-right.svg?color=%23cdd6f4" height="15"  alt=""> Version
- <img src="https://api.iconify.design/mdi:file-account.svg?color=%23cdd6f4" height="15"  alt=""> Publisher