#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprlang #

#specific branch or release
hyprlang_tag="v0.6.3"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

execute_script "hyprutils.sh" # Order is very specific for dependencies are scattered
sleep 1

build_from_git $hyprlang_tag "hyprlang" "cmake_build" "cmake"
