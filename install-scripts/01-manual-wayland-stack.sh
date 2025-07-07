#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Manual Wayland Stack - Build wayland, wayland-protocols, libdisplay-info from source #

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_manual-wayland.log"

printf "\n${NOTE} Building ${SKY_BLUE}Wayland stack from source${RESET}...\n"

# Create build directory
BUILD_DIR="$HOME/hypr-source-builds"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Function to build wayland from source
build_wayland() {
    printf "\n${INFO} Building ${SKY_BLUE}wayland${RESET} from source...\n"
    
    if [ -d "wayland" ]; then
        rm -rf wayland
    fi
    
    (
        git clone https://gitlab.freedesktop.org/wayland/wayland.git
        cd wayland
        # Get latest stable release tag
        git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
        meson setup build --prefix=/usr/local --buildtype=release
        ninja -C build
        sudo ninja -C build install
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} Wayland built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build wayland. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build wayland-protocols from source
build_wayland_protocols() {
    printf "\n${INFO} Building ${SKY_BLUE}wayland-protocols${RESET} from source...\n"
    
    if [ -d "wayland-protocols" ]; then
        rm -rf wayland-protocols
    fi
    
    (
        git clone https://gitlab.freedesktop.org/wayland/wayland-protocols.git
        cd wayland-protocols
        # Get latest stable release tag
        git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
        meson setup build --prefix=/usr/local --buildtype=release
        ninja -C build
        sudo ninja -C build install
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} Wayland-protocols built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build wayland-protocols. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build libdisplay-info from source
build_libdisplay_info() {
    printf "\n${INFO} Building ${SKY_BLUE}libdisplay-info${RESET} from source...\n"
    
    if [ -d "libdisplay-info" ]; then
        rm -rf libdisplay-info
    fi
    
    (
        git clone https://gitlab.freedesktop.org/emersion/libdisplay-info.git
        cd libdisplay-info
        # Get latest stable release tag
        git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
        meson setup build --prefix=/usr/local --buildtype=release
        ninja -C build
        sudo ninja -C build install
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} libdisplay-info built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build libdisplay-info. Check $LOG for details.\n"
        return 1
    fi
}

# Build in dependency order
build_wayland
build_wayland_protocols  
build_libdisplay_info

printf "\n${OK} Wayland stack built successfully from source!\n"
printf "\n%.0s" {1..2}