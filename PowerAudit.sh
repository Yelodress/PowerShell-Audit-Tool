#!/bin/bash

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
    local outputFolderName="output"
    local appFolderName="apps-list"
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
    global_gpu=$(lspci | grep VGA | cut -d':' -f3 | sed 's/^ //')
    
    # Placeholder pour la version du pilote et la date du pilote
    # NOTE: Ces informations nécessitent des commandes spécifiques au fabricant ou au gestionnaire de pilotes
        if command -v glxinfo &> /dev/null; then
        global_gpu_driver_version=$(glxinfo | grep "OpenGL version" | sed 's/^.*: //')
    else
        global_gpu_driver_version="glxinfo not installed"
    fi
    global_gpu_driver_date="To be implemented"
    
    # Exemple pour un GPU NVIDIA (commenté car nécessite une implémentation spécifique)
    # Si vous avez un GPU NVIDIA, vous pouvez décommenter et ajuster ce qui suit
    # global_gpu_driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader)
    # global_gpu_driver_date="To be determined"

    # Pour les GPUs AMD et Intel, il pourrait être nécessaire de consulter des fichiers spécifiques
    # ou d'utiliser des commandes comme `glxinfo` pour obtenir la version du pilote OpenGL comme proxy
}

# System info gathering
gather_system_info() {
    gather_basic_system_info
    gather_cpu_info
    gather_gpu_info
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
    echo "Username,Administrator,Model,Manufacturer,S/N,BIOS Version,Computer name,CPU Model,CPU Cores,CPU Threads per Core,CPU Max Speed,CPU Min Speed,CPU Architecture,GPU,GPU Driver Version,GPU Driver Date" > "$csv_file"
    echo "\"$global_username\",\"$global_is_admin\",\"$global_model\",\"$global_manufacturer\",\"$global_serial_number\",\"$global_bios_version\",\"$global_computer_name\",\"$global_cpu_model\",\"$global_cpu_cores\",\"$global_cpu_threads_per_core\",\"$global_cpu_max_speed\",\"$global_cpu_min_speed\",\"$global_cpu_architecture\",\"$global_gpu\",\"$global_gpu_driver_version\",\"$global_gpu_driver_date\"" >> "$csv_file"
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
  "GPU Driver Date": "$global_gpu_driver_date"
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
}

main
