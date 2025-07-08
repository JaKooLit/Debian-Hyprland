#!/bin/bash

# This script is cleaning up previous manual installation files / directories

# 22 Aug 2024
# Files to be removed from /usr/local/bin

TARGET_DIR="/usr/local/bin"

# Define packages to manually remove (was manually installed previously)
PACKAGES=(
    hyprctl
    hyprpm
    hyprland
    Hyprland
    hyprwayland-scanner
    hyprcursor-util
    hyprland-update-screen
    hyprland-dialog
    hyprland-share-picker
    hyprlock
    hypridle
    cliphist
    pypr
    swappy
    waybar
    magick
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

PARENT_DIR="$SCRIPT_DIR/.."
source "$SCRIPT_DIR/colors.sh" || {
    echo "Failed to source $SCRIPT_DIR/colors.sh"
    exit 1
}

source "$SCRIPT_DIR/parse_args.sh" || {
    echo "${ERROR} Failed to source $SCRIPT_DIR/parse_args.sh"
    exit 1
}

# Change the working directory to the parent directory of the script
cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_pre-clean-up.log"

# Loop through the list of packages
for PKG_NAME in "${PACKAGES[@]}"; do
    # Construct the full path to the file
    FILE_PATH="$TARGET_DIR/$PKG_NAME"

    # Check if the file exists
    if [[ -f "$FILE_PATH" ]]; then
        if [[ $DRY -eq 1 ]]; then
            echo "${NOTE} Not removing $FILE_PATH."
        else
            # Delete the file
            sudo rm "$FILE_PATH"
            echo "Deleted: $FILE_PATH" 2>&1 | tee -a "$LOG"
        fi
    else
        echo "File not found: $FILE_PATH" 2>&1 | tee -a "$LOG"
    fi
done
