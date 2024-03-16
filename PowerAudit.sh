#!/bin/bash

original_lang=$LANG
original_lc_all=$LC_ALL

if ! locale -a | grep -q 'en_US.utf8\|en_US.UTF-8'; then
    echo "Locale en_US.UTF-8 non disponible. Tentative d'activation..."

    # Décommente la ligne pour la locale en_US.UTF-8 (utilise sudo si nécessaire)
    sudo sed -i '/# en_US.UTF-8 UTF-8/s/^# //' /etc/locale.gen
    
    # Exécute locale-gen pour générer la locale (utilise sudo si nécessaire)
    sudo locale-gen

    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    echo "Locale en_US.UTF-8 activée et générée."
else
    echo "Locale en_US.UTF-8 déjà disponible."
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
fi

echo "
 ____                         _             _ _ _   
|  _ \ _____      _____ _ __ / \  _   _  __| (_) |_ 
| |_) / _ \ \ /\ / / _ \ '__/ _ \| | | |/ _\` | | __|
|  __/ (_) \ V  V /  __/ | / ___ \ |_| | (_| | | |_ 
|_|   \___/ \_/\_/ \___|_|/_/   \_\__,_|\__,_|_|\__|v0.6.1 pre-release
"

# Progress-bar definition
total_steps=12

show_custom_progress_bar() {
    local current_step=$1
    local progress_width=50
    local filled=$((current_step * progress_width / total_steps))
    local empty=$((progress_width - filled))
    printf "\r[%-${progress_width}s] %d/12 %s" "${progress_bar:0:$filled}" "$current_step" "$stepName"
    [[ "$current_step" -eq "$total_steps" ]] && echo ""
}

# Folder creation
prepare_folders() {
    outputFolderName="output"
    appFolderName="apps-list"
    mkdir -p "$outputFolderName/$appFolderName"
}

# List programs
list_programs() {
    IFS=':' read -ra dirs_in_path <<< "$PATH"
    for dir in "${dirs_in_path[@]}"; do
        for file in "$dir"/*; do
            [[ -x $file && -f $file ]] && all_apps+=" $(basename "$file")"
        done
    done
}

gather_basic_system_info() {
    global_username=$(whoami)
    global_is_admin=$(id -u)
    [ "$global_is_admin" -eq 0 ] && global_is_admin="Yes" || global_is_admin="No"
    global_model=$(dmidecode -s system-product-name)
    global_manufacturer=$(dmidecode -s system-manufacturer)
    global_serial_number=$(dmidecode -s system-serial-number)
    global_bios_version=$(dmidecode -s bios-version)
    global_computer_name=$(hostname)
}


gather_cpu_info() {
    global_cpu_model=$(lscpu | awk -F: '/Model name/{print $2}' | sed 's/^[ \t]*//;s/[ \t]*$//')
    global_cpu_cores=$(lscpu | awk -F: '/^Core\(s\) per socket/{print $2}' | xargs)
    global_cpu_threads_per_core=$(lscpu | awk -F: '/^Thread\(s\) per core/{print $2}' | xargs)
    global_cpu_max_speed=$(lscpu | awk -F: '/CPU max MHz/{print $2}' | xargs)
    global_cpu_min_speed=$(lscpu | awk -F: '/CPU min MHz/{print $2}' | xargs)
    global_cpu_architecture=$(lscpu | awk -F: '/Architecture/{print $2}' | xargs)
}

gather_gpu_info() {
    # Récupération du modèle du GPU
    global_gpu=$(lspci | grep "VGA compatible controller" | cut -d':' -f3 | sed 's/^ //')

    # Récupération du pilote en cours d'utilisation et des modules de pilotes disponibles
    gpu_info=$(lspci -v -s $(lspci | grep "VGA compatible controller" | cut -d' ' -f1) | grep -E "Kernel driver in use|Kernel modules")
    global_gpu_driver=$(echo "$gpu_info" | grep "Kernel driver in use" | cut -d':' -f2 | sed 's/^ //')
    global_gpu_modules=$(echo "$gpu_info" | grep "Kernel modules" | cut -d':' -f2 | sed 's/^ //')
    
    # Utilisation de glxinfo pour obtenir la version du pilote OpenGL, si possible
    if command -v glxinfo &> /dev/null; then
        glxinfo_output=$(glxinfo 2>/dev/null | grep "OpenGL version" | sed 's/^.*: //')
        if [ -z "$glxinfo_output" ]; then
            global_gpu_driver_version="No display on this PC"
        else
            global_gpu_driver_version=$glxinfo_output
        fi
    else
        global_gpu_driver_version="glxinfo not installed"
    fi
    global_gpu_driver_date="To be implemented"
}

gather_ram_info() {
    # Nécessite des privilèges d'administrateur pour exécuter dmidecode
    # RAM Manufacturer (Prend le premier module de mémoire comme exemple)
    global_ram_manufacturer=$(sudo dmidecode -t memory | grep "Manufacturer" | head -n 1 | awk -F: '{print $2}' | sed 's/^\s*//')
    
    # Total RAM Amount
    global_total_ram_amount=$(free -h | grep "Mem:" | awk '{print $2}')
    
    # RAM Speed (Prend le premier module de mémoire comme exemple)
    global_ram_speed=$(sudo dmidecode -t memory | grep "Speed" | grep -v "Unknown" | head -n 1 | awk -F: '{print $2}' | sed 's/^\s*//')
    
    # RAM Channel et Slot sont un peu plus complexes à déterminer directement via une commande simple.
    # Ici, on compte simplement le nombre de slots utilisés et le nombre total de slots.
    local slots_used=$(sudo dmidecode -t memory | grep "Size" | grep -v "No Module Installed" | wc -l)
    local total_slots=$(sudo dmidecode -t memory | grep "Bank Locator" | wc -l)
    
    global_ram_slot="$slots_used used of $total_slots total"
    
    # RAM Channel - dmidecode ne fournit pas directement cette info, donc ceci est une simplification.
    # Dans les systèmes modernes, la RAM est généralement en mode dual, triple ou quad channel, ce qui dépend de l'architecture spécifique.
    # Une évaluation précise nécessiterait une analyse plus détaillée spécifique au matériel.
    global_ram_channel="To be determined manually"
}

gather_disk_info() {
    # Liste des disques et leurs types
    global_disks_type=$(lsblk -d -o NAME,TYPE | grep disk | awk '{print $2}' | xargs)

    # Modèles des disques
    global_disks_model=$(lsblk -d -o NAME,MODEL | grep disk | awk '{$1=""; print $0}' | sed 's/^\s*//' | xargs)

    # Santé des disques (Nécessite smartmontools)
    # Note: smartctl nécessite des privilèges root pour accéder à la plupart des informations
    if command -v smartctl &>/dev/null; then
        disk_names=$(lsblk -d -o NAME | grep -v NAME | xargs)
        global_disks_health=""
        for disk in $disk_names; do
            health=$(sudo smartctl -H /dev/$disk | grep "SMART overall-health" | awk '{print $6}')
            global_disks_health+="$disk: $health; "
        done
    else
        global_disks_health="smartctl not installed"
    fi

    # Partitions des disques
    global_disks_partitions=$(lsblk -o NAME,TYPE | grep part | awk '{print $1}' | xargs)
}

gather_network_info() {
    # Domaine
    global_domain=$(hostname -d)
    if [ -z "$global_domain" ]; then
        global_domain="Not set or not applicable"
    fi
    
    # Adresse IP (l'interface principale utilisée pour la passerelle par défaut est un bon candidat)
    global_ipaddress=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
    
    # Passerelle
    global_gateway=$(ip route | grep default | awk '{print $3}')
    
    # Serveur DNS (peut varier selon la configuration, ici on regarde resolv.conf comme exemple)
    global_dns=$(grep "nameserver" /etc/resolv.conf | awk '{print $2}' | xargs)
    
    # DHCP (utilise nmcli si disponible, sinon indique une vérification manuelle)
    if command -v nmcli >/dev/null 2>&1; then
        # Ceci suppose que vous avez une connexion nommée "System eth0" ou similaire.
        # Vous devrez peut-être ajuster selon le nom de votre connexion réseau.
        global_dhcp=$(nmcli -t -f IP4.DHCP4.OPTIONS device show | grep 'dhcp_lease_time' | cut -d':' -f2 | xargs)
        if [ -z "$global_dhcp" ]; then
            global_dhcp="Not set or not applicable"
        fi
    else
        global_dhcp="nmcli not installed or DHCP info not available"
    fi
}

gather_misc_info() {
    # Date et heure du scan
    global_scan_date=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Générer un ID de scan simple basé sur la date/heure actuelle
    global_scan_id=$(date "+%Y%m%d%H%M%S")
    
    # Récupérer les informations des imprimantes (CUPS doit être installé)
    global_printers=$(lpstat -a 2>/dev/null | awk '{print $1}' | xargs)
    if [ -z "$global_printers" ]; then
        global_printers="No printers found or CUPS not installed"
    fi
    
    # BitLocker Encryption, Office Version ne sont pas applicables sous Linux
    global_bitlocker_encryption="Not applicable on Linux"
    global_office_version="Not applicable on Linux"
    
    # Date d'installation initiale de l'OS (approche basée sur la date de création du système de fichiers root)
    # Cette commande peut nécessiter des droits d'administration et n'est pas infaillible
    global_initial_install_date=$(sudo tune2fs -l /dev/sda2 | grep 'Filesystem created:' | cut -d':' -f2)
}

# System info gathering
gather_system_info() {
    gather_basic_system_info
    gather_cpu_info
    gather_gpu_info
    gather_ram_info
    gather_disk_info
    gather_network_info
    gather_misc_info
}

# Exporting files
export_files() {
    case $choice in
        1) export_to_csv ;;
        2) export_to_json ;;
        *) echo "Invalid choice." ;;
    esac
}

export_to_csv() {
    local csv_file="$outputFolderName/system_info.csv"
    
    # Ajout des en-têtes CSV pour les nouvelles informations
    echo "Username,Administrator,Model,Manufacturer,S/N,BIOS Version,Computer name,CPU Model,CPU Cores,CPU Threads per Core,CPU Max Speed,CPU Min Speed,CPU Architecture,GPU,GPU Driver Version,GPU Driver Date,RAM Manufacturer,Total RAM Amount,RAM Speed,RAM Slot,RAM Channel,Disks Type,Disks Model,Disks Health,Disks Partitions,Domain,IP Address,Gateway,DNS,DHCP,Printers,BitLocker Encryption,Office Version,Initial Install Date,Scan Date,Scan ID" > "$csv_file"
    
    # Ajout des nouvelles informations aux données à exporter
    echo "\"$global_username\",\"$global_is_admin\",\"$global_model\",\"$global_manufacturer\",\"$global_serial_number\",\"$global_bios_version\",\"$global_computer_name\",\"$global_cpu_model\",\"$global_cpu_cores\",\"$global_cpu_threads_per_core\",\"$global_cpu_max_speed\",\"$global_cpu_min_speed\",\"$global_cpu_architecture\",\"$global_gpu\",\"$global_gpu_driver_version\",\"$global_gpu_driver_date\",\"$global_ram_manufacturer\",\"$global_total_ram_amount\",\"$global_ram_speed\",\"$global_ram_slot\",\"$global_ram_channel\",\"$global_disks_type\",\"$global_disks_model\",\"$global_disks_health\",\"$global_disks_partitions\",\"$global_domain\",\"$global_ipaddress\",\"$global_gateway\",\"$global_dns\",\"$global_dhcp\",\"$global_printers\",\"$global_bitlocker_encryption\",\"$global_office_version\",\"$global_initial_install_date\",\"$global_scan_date\",\"$global_scan_id\"" >> "$csv_file"
}

export_to_json() {
    local json_file="$outputFolderName/system_info.json"
    
    cat << EOF > "$json_file"
{
  "Username": "$global_username",
  "Administrator": "$global_is_admin",
  "Model": "$global_model",
  "Manufacturer": "$global_manufacturer",
  "S/N": "$global_serial_number",
  "BIOS Version": "$global_bios_version",
  "Computer name": "$global_computer_name",
  "CPU Model": "$global_cpu_model",
  "CPU Cores": "$global_cpu_cores",
  "CPU Threads per Core": "$global_cpu_threads_per_core",
  "CPU Max Speed": "$global_cpu_max_speed",
  "CPU Min Speed": "$global_cpu_min_speed",
  "CPU Architecture": "$global_cpu_architecture",
  "GPU": "$global_gpu",
  "GPU Driver Version": "$global_gpu_driver_version",
  "GPU Driver Date": "$global_gpu_driver_date",
  "RAM Manufacturer": "$global_ram_manufacturer",
  "Total RAM Amount": "$global_total_ram_amount",
  "RAM Speed": "$global_ram_speed",
  "RAM Slot": "$global_ram_slot",
  "RAM Channel": "$global_ram_channel",
  "Disks Type": "$global_disks_type",
  "Disks Model": "$global_disks_model",
  "Disks Health": "$global_disks_health",
  "Disks Partitions": "$global_disks_partitions",
  "Domain": "$global_domain",
  "IP Address": "$global_ipaddress",
  "Gateway": "$global_gateway",
  "DNS": "$global_dns",
  "DHCP": "$global_dhcp",
  "Printers": "$global_printers",
  "BitLocker Encryption": "$global_bitlocker_encryption",
  "Office Version": "$global_office_version",
  "Initial Install Date": "$global_initial_install_date",
  "Scan Date": "$global_scan_date",
  "Scan ID": "$global_scan_id"
}
EOF
}

# Main execution flow
main() {
    prepare_folders
    list_programs
    gather_system_info
    echo "Choose your output format: [1] CSV, [2] JSON"
    read -p "Choice: " choice
    [[ ! $choice =~ ^[1-2]$ ]] && { echo "Invalid choice."; exit 1; }
    export_files

    export LANG=$original_lang
    export LC_ALL=$original_lc_all
}

main
