#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hypland-protocols #


#specific branch or release
tag="v0.7.0"
# Allow environment override
if [ -n "${HYPRLAND_PROTOCOLS_TAG:-}" ]; then tag="$HYPRLAND_PROTOCOLS_TAG"; fi

# Dry-run support
DO_INSTALL=1
if [ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_protocols.log"
MLOG="install-$(date +%d-%H%M%S)_protocols2.log"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprland-protocols dependencies${RESET} .... \n" "${INFO}"

# Check if hyprland-protocols directory exists and remove it
if [ -d "hyprland-protocols" ]; then
    rm -rf "hyprland-protocols"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}hyprland-protocols $tag${RESET} ...\n"
if git clone --recursive -b $tag https://github.com/hyprwm/hyprland-protocols.git; then
    cd hyprland-protocols || exit 1
	meson setup build
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo meson install -C build 2>&1 | tee -a "$MLOG" ; then
            printf "${OK} ${MAGENTA}hyprland-protocols $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}hyprland-protocols $tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of hyprland-protocols $tag."
    fi
    #moving the addional logs to Install-Logs directory
    [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprland-protocols tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
