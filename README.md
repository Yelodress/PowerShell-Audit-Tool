<div align="center">
<h1>PowerAudit</h1>
<img alt="Static Badge" src="https://img.shields.io/badge/windows_version-8.1_%7C_10_%7C_11-green?style=for-the-badge&logo=windows&labelColor=%23313244&color=%2389dceb" style="margin-right: 10px">
<img alt="Static Badge" src="https://img.shields.io/badge/Release-v0.6.1-green?style=for-the-badge&labelColor=%23313244&color=%23a6e3a1" style="margin-right: 10px">
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
As a modular script, you can see all unused functions in the [documentation](https://github.com/Yelodress/PowerShell-Audit-Tool/wiki/Documentation).

## 📁 Ouput
<pre>
├── PowerAudit.ps1
└── output
    ├── result.(csv/json) - contain computer specific informations
    └── apps-list
        ├── user-id.(csv/json) - contain user installed software's 
        ├── user-id.(csv/json) - contain user installed software's
        └── user-id.(csv/json) - contain user installed software's
</pre>

## 🚧 Roadmap:
- adding the ability to choose the folder's name (maybe in a textbox)
- checking others disks for Bitlocker's encryption
- Improve the progress-bar design


I'm open to all suggestions :)

If you're facing issues with this script, tell me [here](https://github.com/Yelodress/PowerShell-Audit-Tool/issues).

## Collected data 
### Hardware
#### <img src="https://api.iconify.design/bi:motherboard-fill.svg?color=%23cdd6f4" height="15" alt="">  Motherboard
- Manufacturer
- Model
- Serial number
- BIOS version
#### <img src="https://api.iconify.design/ri:cpu-line.svg?color=%23cdd6f4" height="15" alt=""> CPU 
- Model
- Cores
- Frequency
#### <img src="https://api.iconify.design/bi:gpu-card.svg?color=%23cdd6f4" height="15" alt=""> GPU
- Model
- Drivers version
- Drivers release date
#### <img src="https://api.iconify.design/clarity:memory-solid.svg?color=%23cdd6f4" height="15"  alt=""> RAM
- RAM Manufacturer
- Total RAM amount
- RAM channels
- RAM slots
#### <img src="https://api.iconify.design/mdi:harddisk.svg?color=%23cdd6f4" height="15"  alt=""> Disks
- Total space
- Total free space
- Types
- Models
- Health status
- Partition type
### System
#### <img src="https://api.iconify.design/mdi:account.svg?color=%23cdd6f4" height="15"  alt=""> User
- Username
- User administrator status
#### <img src="https://api.iconify.design/material-symbols:router.svg?color=%23cdd6f4" height="15"  alt=""> Network configuration
- Domain
- IP address
- Gateway
- DNS
- DHCP status
#### <img src="https://api.iconify.design/mdi:microsoft-windows.svg?color=%23cdd6f4" height="15"  alt=""> Operating system
- Version
- Achitecture
- Installation date
- Computer's hostname
#### <img src="https://api.iconify.design/material-symbols:lock.svg?color=%23cdd6f4" height="15"  alt=""> Security
- Bitlocker status
### Others
#### <img src="https://api.iconify.design/mdi:printer.svg?color=%23cdd6f4" height="15"  alt=""> Peripherals
- Printer(s) name(s)
#### <img src="https://api.iconify.design/mdi:microsoft-office.svg?color=%23cdd6f4" height="15"  alt=""> Office
- Office installed version
###  <img src="https://api.iconify.design/material-symbols:deployed-code-update.svg?color=%23cdd6f4" height="15"  alt=""> Apps
- Name
- Version
- Publisher
