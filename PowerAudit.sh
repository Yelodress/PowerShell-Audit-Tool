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

#---------------------------------------------- Hardware informations -----------------------------------------------
stepName="Getting hardware informations"
show_custom_progress_bar 2

cpu_name=$(cat /proc/cpuinfo | grep "model name" | uniq | awk -F ": " '{print $2}')
cpu_cores=$(cat /proc/cpuinfo | grep "cpu cores" | uniq | awk -F ": " '{print $2}')
cpu_max_freq=$(cat /proc/cpuinfo | grep "cpu MHz" | sort -n -r | head -n 1 | awk -F ": " '{print $2}')

#---------------------------------------------- Disks informations -----------------------------------------------
stepName="Getting disks informations"
show_custom_progress_bar 3

disks_info=$(hdparm -i /dev/sda)

#---------------------------------------------- System informations -----------------------------------------------
stepName="Getting system informations"
show_custom_progress_bar 4

osInfo=$(lsb_release -a)
initialInstallDate=$(ls -ld --time-style=long-iso / | awk '{print $6}')

#---------------------------------------------- Network informations -----------------------------------------------
stepName="Getting network informations"
show_custom_progress_bar 5

networkConf=$(ip addr)
#---------------------------------------------- Bitlocker encryption check -----------------------------------------------
stepName="Encryption check"
show_custom_progress_bar 6

isEncrypted=$(lsblk -o NAME,FSTYPE | grep "crypto_LUKS" | cut -d ' ' -f 2)
isEncrypted=${isEncrypted:-"Not encrypted"}

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

#---------------------------------------------- Generating scan informations -----------------------------------------------
stepName="Generating scan informations"
show_custom_progress_bar 8

currentDate=$(date +%F)
scanID=$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')

#---------------------------------------------- Checking if current user is admin -----------------------------------------------
stepName="Checking your role"
show_custom_progress_bar 10

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
cpu=$(lscpu | grep "Model name" | cut -d':' -f2 | awk '{$1=$1}')
numCores=$(lscpu | grep "Core(s) per socket" | cut -d':' -f2 | awk '{$1=$1}')
frequency=$(lscpu | grep "CPU max MHz" | cut -d':' -f2 | awk '{$1=$1}')
gpu=$(lspci | grep VGA | cut -d':' -f3)
gpuDriverVersion=$(glxinfo | grep "OpenGL version" | cut -d':' -f2 | awk '{$1=$1}')
gpuDriverDate=$(glxinfo | grep "OpenGL version" | cut -d':' -f3 | awk '{$1=$1}')
ramManufacturer=$(dmidecode -t memory | grep Manufacturer | awk '{print $2}' | head -1)
totalRAM=$(free -h | awk '/Mem/{print $2}')
ramSpeed=$(dmidecode -t memory | grep "Speed" | awk '{print $2}' | head -1)
ramChannels=$(dmidecode -t memory | grep "Locator" | awk '{print $2}' | head -1)
ramSlots=$(dmidecode -t memory | grep "Locator" | awk '{print $2}' | tail -1)
totalDiskSpace=$(df -h --total | grep "total" | awk '{print $2}')
totalFreeSpace=$(df -h --total | grep "total" | awk '{print $4}')
diskType=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $2}')
diskModel=$(lsblk -d -o NAME,MODEL | grep disk | awk '{print $2}')
diskHealth=$(lsblk -d -o NAME,STATE | grep disk | awk '{print $2}')
diskPartitions=$(lsblk -l | grep disk | awk '{print $6}')
os=$(lsb_release -d | cut -f2)
version=$(lsb_release -r | cut -f2)
architecture=$(uname -m)
domain=$(dnsdomainname)
ipAddress=$(hostname -I)
gateway=$(ip route | grep default | awk '{print $3}')
dns=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
dhcp=$(cat /etc/network/interfaces | grep dhcp | awk '{print $1}')
printers=$(lpstat -p | awk '{print $2}')
bitlockerEncryption=$(lsblk -o NAME,FSTYPE | grep crypt | wc -l)
officeVersion="No"
initialInstallDate=$(date -d @0)
scanDate=$(date +"%Y-%m-%d")
scanID="123456"

#----------------------------------------------- Exporting all CSV files ------------------------------------------------

# Définition de la fonction csv
csv()
{
    local items=("$@")

    # quote and escape as needed
    # https://datatracker.ietf.org/doc/html/rfc4180
    for i in "${!items[@]}"
    do
        if [[ "${items[$i]}" =~ [,\"] ]]
        then
            items[$i]=\"$(echo -n "${items[$i]}" | sed 's/"/""/g')\"
        fi
    done

    (
    IFS=,
    echo "${items[*]}"
    )
}

stepName="Exporting files"
show_custom_progress_bar 12

echo "Choose your output format"
echo "1: CSV"
echo "2: JSON"
read -p "Choice: " choice

if [ "$choice" -eq "1" ]; then
    # Export to CSV format
    {
    # Utilisation de la fonction csv pour écrire une ligne CSV
    csv "$userName" "$isAdmin" "$model" "$manufacturer" "$serialNumber" "$biosVersion" "$computerName" "$cpu" "$numCores" "$frequency" "$gpu" "$gpuDriverVersion" "$gpuDriverDate" "$ramManufacturer" "$totalRAM" "$ramSpeed" "$ramChannels" "$ramSlots" "$totalDiskSpace" "$totalFreeSpace" "$diskType" "$diskModel" "$diskHealth" "$diskPartitions" "$os" "$version" "$architecture" "$domain" "$ipAddress" "$gateway" "$dns" "$dhcp" "$printers" "$bitlockerEncryption" "$officeVersion" "$initialInstallDate" "$scanDate" "$scanID"
    } >"$outputFolderName/output.csv"
    echo "CSV exported successfully."
elif [ "$choice" -eq "2" ]; then
    # Export to JSON format
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
    echo "JSON exported successfully."
else
    echo "Not valid choice."
fi
