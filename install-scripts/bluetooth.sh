#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Bluetooth #

blue=(
    bluez
    blueman
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

PARENT_DIR=$SCRIPT_DIR/..

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_bluetooth.log"

# Bluetooth
echo "${NOTE} Installing ${SKY_BLUE}Bluetooth${RESET} Packages..."
for BLUE in "${blue[@]}"; do
    install_package "$BLUE" "$LOG"
done

echo " Activating ${YELLOW}Bluetooth${RESET} Services..."
if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE} Not enabling service bluetooth.service with systemctl enable --now"
else
    sudo systemctl enable --now bluetooth.service 2>&1 | tee -a "$LOG"
fi

newlines 2
