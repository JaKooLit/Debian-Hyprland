#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package#

#specific branch or release

hyprland=(
    libxcb-errors-dev
    hyprland
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland2.log"

# Installation of dependencies

for PKG1 in "${hyprland[@]}"; do
    install_package "$PKG1" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
        exit 1
    fi
done

# Clone, build, and install Hyprland using Cmake
printf "${NOTE} Installing Hyprland"

# Check if Hyprland folder exists and remove it
#!/bin/bash

# Get the OS name from the release file
os_name=$(grep '^NAME=' /etc/os-release | tr -d '"' | cut -d= -f2)

# Check if the OS is Debian or Ubuntu
if [[ "$os_name" == "Debian GNU/Linux" ]]; then
    for PKG1 in "${hyprland[@]}"; do
        install_package "$PKG1" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $PKG1 Hyprland installation failed, Please check the installation logs"
            exit 1
        fi
    done

elif [[ "$os_name" == "Ubuntu" ]]; then
   printf "${NOTE} Adding Universe repo"
   sudo add-apt-repository universe
   sudo apt update
   for PKG1 in "${hyprland[@]}"; do
        install_package "$PKG1" 2>&1 | tee -a "$LOG"
        if [ $? -ne 0 ]; then
            echo -e "\e[1A\e[K${ERROR} - $PKG1 Hyprland installation failed, Please check the installation logs"
            exit 1
        fi
    done
fi
clear