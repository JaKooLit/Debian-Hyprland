#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hypridle #

idle=(
    libsdbus-c++-dev
)

#specific branch or release
hypridle_tag="v0.1.6"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypridle_install_dependencies.log"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hypridle dependencies${RESET} .... \n" "${INFO}"

for PKG1 in "${idle[@]}"; do
    re_install_package "$PKG1" 2>&1 | tee -a "$LOG"
    if ! re_install_package "$PKG1" 2>&1 | tee -a "$LOG"; then
        echo -e "\e[1A\e[K${ERROR} - ${YELLOW}$PKG1${RESET} Package installation failed, Please check the installation logs"
        exit 1
    fi
done

build_from_git $hypridle_tag "hypridle" "cmake_build" "cmake"
