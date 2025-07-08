#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprutils #

#specific branch or release
hyprutils_tag="v0.7.1"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

build_from_git $hyprutils_tag "hyprutils" "cmake_build" "cmake"
