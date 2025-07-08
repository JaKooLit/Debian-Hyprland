#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprland-qt-support #

#specific branch or release
hyprland_qt_support="v0.1.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

build_from_git $hyprland_qt_support "hyprland-qt-support" "hyprland-qt-support" "cmake"
