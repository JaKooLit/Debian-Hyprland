#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprland-protocols #

#specific branch or release
hyprland_protocols_tag="v0.6.4"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

build_from_git $hyprland_protocols_tag "hyprland-protocols" "meson" "meson"
