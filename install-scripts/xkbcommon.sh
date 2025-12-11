#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# xkbcommon #

xkbcommon=(
bison
libzip-dev
librsvg2-dev
)

#specific branch or release
tag="xkbcommon-1.13.1"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_xkbcommon.log"
MLOG="install-$(date +%d-%H%M%S)_xkbcommon.log"

# Installation of dependencies
printf "\n%s - Installing xkbcommon dependencies.... \n" "${NOTE}"

for PKG1 in "${xkbcommon[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if xkbcommon folder exists and remove it
if [ -d "libxkbcommon" ]; then
    printf "${NOTE} Removing existing libxkbcommon folder...\n"
    rm -rf "libxkbcommon"
fi

# Clone and build 
printf "${NOTE} Installing xkbcommon...\n"
if git clone --recursive -b $tag https://github.com/xkbcommon/libxkbcommon.git; then
    cd libxkbcommon || exit 1
    meson setup build --libdir=/usr/local/lib
    meson compile -C build
    if sudo meson install -C build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} xkbcommon installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for xkbcommon." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for xkbcommon." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}


