#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# aquamarine #


#specific branch or release
tag="v0.9.3"
# Allow environment override
if [ -n "${AQUAMARINE_TAG:-}" ]; then tag="$AQUAMARINE_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_aquamarine.log"

# For this branch, prefer Debian packages for aquamarine by default
printf "\n%s - Installing ${YELLOW}aquamarine (Debian package)${RESET} .... \n" "${INFO}"

if [ $DO_INSTALL -eq 1 ]; then
    install_package "libaquamarine8" 2>&1 | tee -a "$LOG"
    install_package "libaquamarine-dev" 2>&1 | tee -a "$LOG"
else
    echo "${NOTE} DRY RUN: Would install libaquamarine8 and libaquamarine-dev from APT."
fi

printf "\n%.0s" {1..2}