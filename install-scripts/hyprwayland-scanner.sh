#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprwayland-scanner #

scan_depend=(
    libpugixml-dev
)

#specific branch or release
tag="v0.4.5"
# Allow environment override
if [ -n "${HYPRWAYLAND_SCANNER_TAG:-}" ]; then tag="$HYPRWAYLAND_SCANNER_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprwayland-scanner.log"

## For this branch, prefer Debian package for hyprwayland-scanner
printf "\n%s - Installing hyprwayland-scanner (Debian package).... \n" "${NOTE}"

if [ $DO_INSTALL -eq 1 ]; then
  install_package "hyprwayland-scanner" 2>&1 | tee -a "$LOG"
else
  echo "${NOTE} DRY RUN: Would install hyprwayland-scanner from APT."
fi

printf "\n%.0s" {1..2}

