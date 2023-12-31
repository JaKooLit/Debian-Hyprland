#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Pywal Colors) #

pywal=(
  imagemagick
  python3-pip
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +'%d-%H%M%S')_pywal.log"

# Installing Pywal dependencies
for package in "${pywal[@]}"; do
  install_package "$package" || exit 1
done

## Installing pywal colors
printf "\n%s - Installing Pywal.... \n" "${NOTE}"
sudo pip3 install pywal --break-system-packages 2>&1 | tee -a "$LOG"

clear
