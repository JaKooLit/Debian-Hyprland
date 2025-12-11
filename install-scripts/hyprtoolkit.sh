#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprtoolkit #

#specific branch or release
tag="v0.4.1"
# Allow environment override
if [ -n "${HYPRTOOLKIT_TAG:-}" ]; then tag="$HYPRTOOLKIT_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprtoolkit.log"
MLOG="install-$(date +%d-%H%M%S)_hyprtoolkit2.log"

# Clone, build, and install using Cmake
printf "${NOTE} Cloning hyprtoolkit...\n"

# Check if hyprtoolkit folder exists and remove it
if [ -d "hyprtoolkit" ]; then
  printf "${NOTE} Removing existing hyprtoolkit folder...\n"
  rm -rf "hyprtoolkit" 2>&1 | tee -a "$LOG"
fi

if git clone -b $tag "https://github.com/hyprwm/hyprtoolkit.git"; then
  cd "hyprtoolkit" || exit 1
  cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr/local -S . -B ./build
  cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
  if [ $DO_INSTALL -eq 1 ]; then
    if sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
      printf "${OK} hyprtoolkit installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
      echo -e "${ERROR} Installation failed for hyprtoolkit." 2>&1 | tee -a "$MLOG"
    fi
  else
    echo "${NOTE} DRY RUN: Skipping installation of hyprtoolkit $tag."
  fi
  [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/
  cd ..
else
  echo -e "${ERROR} Download failed for hyprtoolkit" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}


