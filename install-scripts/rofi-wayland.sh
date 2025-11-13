#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Rofi-Wayland) #

rofi=(
  bison
  flex
  pandoc
  doxygen
  cppcheck
  imagemagick
  libmpdclient-dev
  libnl-3-dev
  libasound2-dev
  libstartup-notification0-dev
  libwayland-client++1
  libwayland-dev
  libcairo-5c-dev
  libcairo2-dev
  libpango1.0-dev
  libgdk-pixbuf-2.0-dev
  libxcb-keysyms1-dev
  libwayland-client0
  libxcb-ewmh-dev
  libxcb-cursor-dev
  libxcb-icccm4-dev
  libxcb-randr0-dev
  libxcb-render-util0-dev
  libxcb-util-dev
  libxcb-xkb-dev
  libxcb-xinerama0-dev
  libxkbcommon-dev
  libxkbcommon-x11-dev
  ohcount
  wget
)

# variables 
rofi_tag="1.7.9+wayland1"
release_url="https://github.com/lbonn/rofi/releases/download/1.7.9%2Bwayland1/rofi-1.7.9+wayland1.tar.gz"


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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_rofi_wayland.log"

# For this branch, prefer Debian rofi (with Wayland support) instead of building rofi-wayland
printf "\n%s - Installing ${SKY_BLUE}rofi (Debian package, Wayland-capable)${RESET}.... \n" "${INFO}"

if [ $DO_INSTALL -eq 1 ]; then
  install_package "rofi" 2>&1 | tee -a "$LOG"
  # Optional: headers for themes or building scripts
  install_package "rofi-dev" 2>&1 | tee -a "$LOG" || true
else
  echo "${NOTE} DRY RUN: Would install rofi and rofi-dev from APT (Wayland-capable rofi 2.0.0)."
fi

printf "\n%.0s" {1..2}
