#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Aylur's GTK Shell #

ags=(
    node-typescript
    npm
    meson
    libgjs-dev
    gjs
    libgtk-layer-shell-dev
    libgtk-3-dev
    libpam0g-dev
    libpulse-dev
    libdbusmenu-gtk3-dev
    libsoup-3.0-dev
)

f_ags=(
    npm
)

build_dep=(
    pam
)

# specific tags to download
ags_tag="v1.9.0"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

PARENT_DIR=$SCRIPT_DIR/..

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_ags.log"
MLOG="install-$(date +%d-%H%M%S)_ags2.log"

# Check if AGS is installed
if command -v ags &>/dev/null; then
    AGS_VERSION=$(ags -v | awk '{print $NF}')
    if [[ "$AGS_VERSION" == "1.9.0" ]]; then
        echo "${INFO} ${MAGENTA}Aylur's GTK Shell v1.9.0${RESET} is already installed. Skipping installation."
        newlines 1
        exit 0
    fi
fi

# Installation of main components
newlines 1
echo "${INFO} - Installing ${SKY_BLUE}Aylur's GTK shell $ags_tag${RESET} Dependencies"

# Installing ags Dependencies
for PKG1 in "${ags[@]}"; do
    install_package "$PKG1" "$LOG"
done

for force_ags in "${f_ags[@]}"; do
    re_install_package "$force_ags" 2>&1 | tee -a "$LOG"
done

newlines 1

for PKG1 in "${build_dep[@]}"; do
    build_dep "$PKG1" "$LOG"
done

if [[ $DRY -eq 1 ]]; then
    echo "${NOTE} Not installing typescript with npm install --global" | tee -a "$LOG"
else
    #install typescript by npm
    sudo npm install --global typescript 2>&1 | tee -a "$LOG"
fi

# ags v1
echo "${NOTE} Install and Compiling ${SKY_BLUE}Aylur's GTK shell $ags_tag${RESET}.."

# Check if directory exists and remove it
if [ -d "ags" ]; then
    echo "${NOTE} Removing existing ags directory..."
    remove_dir "ags" "$LOG"
fi

newlines 1
echo "${INFO} Kindly Standby...cloning and compiling ${SKY_BLUE}Aylur's GTK shell $ags_tag${RESET}..."
newlines 1

if [[ $NO_BUILD -eq 1 ]]; then
    echo "${NOTE} Not cloning or building ags"
else
    # Clone repository with the specified tag and capture git output into MLOG
    if git clone --depth=1 https://github.com/JaKooLit/ags_v1.9.0.git; then
        cd "$PARENT_DIR"/ags_v1.9.0 || exit 1
        npm install
        meson setup build
        if sudo meson install -C build 2>&1 | tee -a "$MLOG"; then
            newlines 1
            echo "${OK} ${YELLOW}Aylur's GTK shell $ags_tag${RESET} installed successfully." 2>&1 | tee -a "$MLOG"
        else
            newlines 1
            echo "${ERROR} ${YELLOW}Aylur's GTK shell $ags_tag${RESET} Installation failed" 2>&1 | tee -a "$MLOG"
        fi
        # Move logs to Install-Logs directory
        mv "$MLOG" "$PARENT_DIR"/Install-Logs/ || true
        cd ..
    else
        echo -e "\n${ERROR} Failed to download ${YELLOW}Aylur's GTK shell $ags_tag${RESET} Please check your connection\n" 2>&1 | tee -a "$LOG"
        mv "$MLOG" "$PARENT_DIR"/Install-Logs/ || true
        exit 1
    fi
fi

newlines 2
