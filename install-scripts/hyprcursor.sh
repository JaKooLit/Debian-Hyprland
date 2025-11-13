#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprcursor #

cursor=(
libzip-dev
librsvg2-dev
)

#specific branch or release
tag="v0.1.13"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprcursor.log"

# For this branch, prefer Debian packages for hyprcursor by default
printf "\n%s - Installing hyprcursor (Debian packages).... \n" "${NOTE}"

if [ $DO_INSTALL -eq 1 ]; then
  # runtime and dev package
  install_package "libhyprcursor0" 2>&1 | tee -a "$LOG"
  install_package "libhyprcursor-dev" 2>&1 | tee -a "$LOG"
else
  echo "${NOTE} DRY RUN: Would install libhyprcursor0 and libhyprcursor-dev from APT."
fi

printf "\n%.0s" {1..2}


