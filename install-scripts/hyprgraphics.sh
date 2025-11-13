#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprgraphics #

hyprgraphics=(
	libmagic
)

#specific branch or release
tag="v0.1.6"
# Allow environment override
if [ -n "${HYPRGRAPHICS_TAG:-}" ]; then tag="$HYPRGRAPHICS_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprgraphics.log"

# For this branch, prefer Debian packages for hyprgraphics by default
printf "\n%s - Installing ${YELLOW}hyprgraphics (Debian packages)${RESET} .... \n" "${INFO}"

if [ $DO_INSTALL -eq 1 ]; then
  install_package "libhyprgraphics2" 2>&1 | tee -a "$LOG"
  install_package "libhyprgraphics-dev" 2>&1 | tee -a "$LOG"
else
  echo "${NOTE} DRY RUN: Would install libhyprgraphics2 and libhyprgraphics-dev from APT."
fi

printf "\n%.0s" {1..2}