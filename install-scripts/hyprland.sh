#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprland #

#specific branch or release
hyprland_tag="v0.49.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

verbose_log "Need to build hyprland dependencies from source first."
# Dependencies
execute_script "hyprcursor.sh" # Depends on hyprlang
sleep 1
execute_script "hyprgraphics.sh"
sleep 1
execute_script "hyprland-qt-support.sh"
sleep 1
execute_script "hyprland-qtutils.sh"
sleep 1
execute_script "hyprwayland-scanner.sh"
sleep 1
execute_script "aquamarine.sh"
sleep 1
execute_script "hyprland-protocols.sh"
sleep 1
execute_script "hypridle.sh"
sleep 1
execute_script "hyprlock.sh"

build_from_git $hyprland_tag "hyprland" "cmake_build" "cmake"
