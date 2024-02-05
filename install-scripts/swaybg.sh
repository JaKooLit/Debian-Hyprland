#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Swaybg - Static Wallpaper Utility #

swaybg=(
swaybg
libc6
libcairo2
libglib2.0-0
libwayland-client0
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swaybg2.log"
MLOG="install-$(date +%d-%H%M%S)_swaybg.log"

printf "${NOTE} Installing swaybg\n"
  for SWAYBG in "${swaybg[@]}"; do
    install_package "$SWAYBG" 2>&1 | tee -a "$LOG"
    [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $SWAYBG install had failed, please check the install.log"; exit 1; }
  done

clear
