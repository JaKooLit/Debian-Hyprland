#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprcursor #

#specific branch or release
hyprcursor_tag="v0.1.12"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

execute_script "hyprlang.sh" # Depends on hyprutils
sleep 1

build_from_git $hyprcursor_tag "hyprcursor" "cmake_build" "cmake"
