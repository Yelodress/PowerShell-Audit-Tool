#!/bin/bash

echo "
 ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _\` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__|v0.6.1
"

#-------------------------------------------- Progress-bar definition ---------------------------------------------
total_steps=12

function show_custom_progress_bar {
    current_step=$1
    progress_width=50
    progress_bar=$(printf "%0.s-" $(seq 1 $((current_step * progress_width / total_steps))))
    printf "\r[%-${progress_width}s] %d/12 %s" "$progress_bar" "$current_step" "$stepName"
    [ "$current_step" -eq "$total_steps" ] && echo ""
}

#----------------------------------------------- Folder creation ------------------------------------------------
stepName="Creating folders"
show_custom_progress_bar 1

appFolderName="apps-list"
outputFolderName="output"
[ ! -d "$outputFolderName" ] && mkdir -p "$outputFolderName/$appFolderName"

#---------------------------------------------- Listing programs -----------------------------------------------
stepName="Listing all programs"
show_custom_progress_bar 7

IFS=':' read -ra dirs_in_path <<< "$PATH"
all_apps=""

for dir in "${dirs_in_path[@]}"; do
    for file in "$dir"/*; do
        if [[ -x $file && -f $file ]]; then
            all_apps="$all_apps $(basename "$file")"
        fi
    done
done

#------------------------------------------------- Creating global tab --------------------------------------------------
stepName="Generating tab"
show_custom_progress_bar 11

userName=$(whoami)
isAdmin=$(id -u)
[ "$isAdmin" -eq 0 ] && isAdmin="Yes" || isAdmin="No"

model=$(dmidecode -s system-product-name)
manufacturer=$(dmidecode -s system-manufacturer)
serialNumber=$(dmidecode -s system-serial-number)
biosVersion=$(dmidecode -s bios-version)
computerName=$(hostname)
cpu=$(lscpu | awk '/Model name/ {print $3,$4,$5,$6,$7}')
numCores=$(lscpu | grep "Core(s) per socket" | awk '{print $NF}')
frequency=$(lscpu | grep "CPU max MHz" | awk '{print $NF}')
gpu=$(lspci | grep VGA | cut -d':' -f3)
ramManufacturer=$(sudo dmidecode -t memory | grep Manufacturer | awk '{print $2}' | head -1)
totalRAM=$(free -h | awk '/Mem/{print $2}')
ramSpeed=$(sudo dmidecode -t 17 | grep -i speed | grep -v "Configured" | awk '{print $2 " " $3}' | head -1)
ramChannels=$(sudo dmidecode -t memory | grep "Locator" | awk '{print $2}' | head -1)
ramSlots=$(sudo dmidecode -t memory | grep "Locator" | awk '{print $2}' | tail -1)
totalDiskSpace=$(df -h --total | grep "total" | awk '{print $2}')
totalFreeSpace=$(df -h --total | grep "total" | awk '{print $4}')
diskType=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $2}')
diskModel=$(cat /sys/class/block/sda/device/model )
diskPartitions=$(lsblk -l | grep disk | awk '{print $6}')
os=$(uname -a)
version=$(lsb_release -r | cut -f2)
architecture=$(uname -m)
domain=$(dnsdomainname)
ipAddress=$(hostname -I)
gateway=$(ip route | grep default | awk '{print $3}')
dns=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
dhcp=$(ip route show | grep "default via" | grep "dev eno1" | grep "proto dhcp" | awk '{print $5}')
#printers=$(lpstat -p | awk '{print $2}')
bitlockerEncryption=$(lsblk -o NAME,FSTYPE | grep crypt | wc -l)
officeVersion="No"
initialInstallDate=$(date -d @0)
scanDate=$(date +"%Y-%m-%d")
scanID="123456"

#----------------------------------------------- Exporting all files ------------------------------------------------

stepName="Exporting all files"
show_custom_progress_bar 12

echo "Choose your output format"
echo "1: CSV"
echo "2: JSON"
read -p "Choice: " choice

if [ "$choice" -eq "1" ]; then
    # Assurez-vous que le dossier pour les CSV existe
    
    mkdir -p "$outputFolderName"
    mkdir -p "$outputFolderName/$appFolderName"
    
    # Export to CSV format for applications list
    {
        echo "Application Name"
        echo "$all_apps" | tr ' ' '\n'
    } > "$outputFolderName/$appFolderName/apps-list.csv"
    echo "CSV apps-list exported successfully."

    # Export system information to CSV format
    {
        echo "Username,Administrator,Model,Manufacturer,S/N,BIOS Version,Computer name,CPU,Number of cores,Frequency,GPU,RAM manufacturer,Total RAM amount,RAM speed,RAM Channel,RAM Slot,Total disk space,Total free space,Disks type,Disks model,OS,Version,Architecture,Domain,IP Address,Gateway,DNS,DHCP,Printers,Bitlocker encryption,Office Version,Initial install date,Scan date,Scan ID"
        echo "\"$userName\",\"$isAdmin\",\"$model\",\"$manufacturer\",\"$serialNumber\",\"$biosVersion\",\"$computerName\",\"$cpu\",\"$numCores\",\"$frequency\",\"$gpu\",\"$ramManufacturer\",\"$totalRAM\",\"$ramSpeed\",\"$ramChannels\",\"$ramSlots\",\"$totalDiskSpace\",\"$totalFreeSpace\",\"$diskType\",\"$diskModel\",\"$os\",\"$version\",\"$architecture\",\"$domain\",\"$ipAddress\",\"$gateway\",\"$dns\",\"$dhcp\",\"$printers\",\"$bitlockerEncryption\",\"$officeVersion\",\"$initialInstallDate\",\"$scanDate\",\"$scanID\""
    } > "$outputFolderName/output.csv"
    echo "CSV output exported successfully."
elif [ "$choice" -eq "2" ]; then
    # Assurez-vous que le dossier pour les JSON existe
    mkdir -p "$outputFolderName"
    mkdir -p "$outputFolderName/$appFolderName"

    # Export to JSON format for applications list
    {
        echo "{"
        echo "  \"Applications\": ["
        echo "$all_apps" | tr ' ' '\n' | awk '{print "    \""$0"\","}' | sed '$ s/,$//'
        echo "  ]"
        echo "}"
    } > "$outputFolderName/$appFolderName/apps-list.json"
    echo "JSON apps-list exported successfully."

    # Export system information to JSON format
    {
        echo "{"
        echo "  \"Username\": \"$userName\","
        echo "  \"Administrator\": \"$isAdmin\","
        echo "  \"Model\": \"$model\","
        echo "  \"Manufacturer\": \"$manufacturer\","
        echo "  \"S/N\": \"$serialNumber\","
        echo "  \"BIOS Version\": \"$biosVersion\","
        echo "  \"Computer name\": \"$computerName\","
        echo "  \"CPU\": \"$cpu\","
        echo "  \"Number of cores\": \"$numCores\","
        echo "  \"Frequency\": \"$frequency MHz\","
        echo "  \"GPU\": \"$gpu\","
        echo "  \"GPU driver version\": \"$gpuDriverVersion\","
        echo "  \"GPU Driver date\": \"$gpuDriverDate\","
        echo "  \"RAM manufacturer\": \"$ramManufacturer\","
        echo "  \"Total RAM amount\": \"$totalRAM\","
        echo "  \"RAM speed\": \"$ramSpeed MHz\","
        echo "  \"RAM Channel\": \"$ramChannels\","
        echo "  \"RAM Slot\": \"$ramSlots\","
        echo "  \"Total disk space\": \"$totalDiskSpace\","
        echo "  \"Total free space\": \"$totalFreeSpace\","
        echo "  \"Disks type\": \"$diskType\","
        echo "  \"Disks model\": \"$diskModel\","
        echo "  \"Disks health\": \"$diskHealth\","
        echo "  \"Disks partitions\": \"$diskPartitions\","
        echo "  \"OS\": \"$os\","
        echo "  \"Version\": \"$version\","
        echo "  \"Architecture\": \"$architecture\","
        echo "  \"Domain\": \"$domain\","
        echo "  \"IP Address\": \"$ipAddress\","
        echo "  \"Gateway\": \"$gateway\","
        echo "  \"DNS\": \"$dns\","
        echo "  \"DHCP\": \"$dhcp\","
        echo "  \"Printers\": \"$printers\","
        echo "  \"Bitlocker encryption\": \"$bitlockerEncryption\","
        echo "  \"Office Version\": \"$officeVersion\","
        echo "  \"Initial install date\": \"$initialInstallDate\","
        echo "  \"Scan date\": \"$scanDate\","
        echo "  \"Scan ID\": \"$scanID\""
        echo "}"
    } >"$outputFolderName/output.json"
    echo "JSON output exported successfully."
else
    echo "Not valid choice."
fi
