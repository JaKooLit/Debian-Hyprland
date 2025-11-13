#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyplang #


#specific branch or release
tag="v0.6.4"
# Allow environment override
if [ -n "${HYPRLANG_TAG:-}" ]; then tag="$HYPRLANG_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlang.log"

# For this branch, prefer Debian packages for hyprlang by default
printf "\n%s - Installing ${YELLOW}hyprlang (Debian packages)${RESET} .... \n" "${INFO}"

if [ $DO_INSTALL -eq 1 ]; then
    install_package "libhyprlang2" 2>&1 | tee -a "$LOG"
    install_package "libhyprlang-dev" 2>&1 | tee -a "$LOG"
else
    echo "${NOTE} DRY RUN: Would install libhyprlang2 and libhyprlang-dev from APT."
fi

printf "\n%.0s" {1..2}
