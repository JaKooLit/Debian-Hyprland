#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprwayland-scanner #

#specific branch or release
hyprwayland_scanner_tag="v0.4.4"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

build_from_git $hyprwayland_scanner_tag "hyprwayland-scanner" "hyprwayland-scanner" "cmake"
