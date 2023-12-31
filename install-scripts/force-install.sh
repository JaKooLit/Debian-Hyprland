#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# force reinstall packages cause it says its already installed but still not
# some users report that they need to install this packages

force=(
  imagemagick
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_force.log"

printf "${NOTE} Force installing packages...\n"
 for FORCE in "${force[@]}"; do
   sudo apt-get --reinstall install -y "$FORCE" 2>&1 | tee -a "$LOG"
   [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $FORCE install had failed, please check the install.log"; exit 1; }
  done

clear