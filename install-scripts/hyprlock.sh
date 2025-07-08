#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprlock #

lock=(
    libpam0g-dev
    libgbm-dev
    libdrm-dev
    libmagic-dev
    libsdbus-c++-dev
)

#specific branch or release
hyprlock_tag="v0.8.2"

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

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlock_install_dependencies.log"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprlock dependencies${RESET} .... \n" "${INFO}"

for PKG1 in "${lock[@]}"; do
    re_install_package "$PKG1" "$LOG"
done

build_from_git $hyprlock_tag "hyprlock" "cmake_build" "cmake"
