#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprland-qtutils #

#specific branch or release
hyprland_qtutils_tag="v0.1.4"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

build_from_git $hyprland_qtutils_tag "hyprland-qtutils" "cmake_build" "cmake"
