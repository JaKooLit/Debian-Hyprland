#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# This is to be use for installing hyprland plugins

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr_eco.log"

# Hyprland Plugins
# pyprland https://github.com/hyprland-community/pyprland installing using python
pip install pyprland 2>&1 | tee -a "$LOG" || True

clear

