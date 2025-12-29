#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem
# hyprwire

# Specific branch or release (honor env override)
tag="v0.1.0"
if [ -n "${HYPRWIRE_TAG:-}" ]; then tag="$HYPRWIRE_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprwire.log"
MLOG="install-$(date +%d-%H%M%S)_hyprwire2.log"

printf "${NOTE} Installing hyprwire $tag...\n"

# Remove existing tree if present
if [ -d "hyprwire" ]; then
  printf "${NOTE} Removing existing hyprwire folder...\n"
  rm -rf "hyprwire" 2>&1 | tee -a "$LOG"
fi

# Clone and build
if git clone --recursive -b "$tag" https://github.com/hyprwm/hyprwire.git; then
  cd hyprwire || exit 1
  cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
  cmake --build build -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
  if [ $DO_INSTALL -eq 1 ]; then
    if sudo cmake --install build 2>&1 | tee -a "$MLOG" ; then
      printf "${OK} hyprwire $tag installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
      echo -e "${ERROR} Installation failed for hyprwire $tag" 2>&1 | tee -a "$MLOG"
    fi
  else
    echo "${NOTE} DRY RUN: Skipping installation of hyprwire $tag."
  fi
  [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/
  cd ..
else
  echo -e "${ERROR} Download failed for hyprwire $tag" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
