#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Adding users into input group #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_input.log"

# Check if the 'input' group exists
if grep -q '^input:' /etc/group; then
    echo "${OK} ${MAGENTA}input${RESET} group exists."
else
    echo "${NOTE} ${MAGENTA}input${RESET} group doesn't exist. Creating ${MAGENTA}input${RESET} group..."
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} Not adding the nonexistent group, input, with sudo groupadd"
    else
        sudo groupadd input
    fi
    echo "${MAGENTA}input${RESET} group created" >>"$LOG"
fi

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE}Not adding $(whoami) to the input group with sudo usermod -aG"
else
    # Add the user to the 'input' group
    sudo usermod -aG input "$(whoami)"
    echo "${OK} ${YELLOW}user${RESET} added to the ${MAGENTA}input${RESET} group. Changes will take effect after you log out and log back in." >>"$LOG"
fi

newlines 2
