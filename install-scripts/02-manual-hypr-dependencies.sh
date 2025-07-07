#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Manual Hypr Dependencies - Build all hypr* dependencies from source #

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_manual-hypr-deps.log"

printf "\n${NOTE} Building ${SKY_BLUE}Hypr dependencies from source${RESET}...\n"

# Create build directory
BUILD_DIR="$HOME/hypr-source-builds"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Function to build hyprwayland-scanner from source
build_hyprwayland_scanner() {
    printf "\n${INFO} Building ${SKY_BLUE}hyprwayland-scanner${RESET} from source...\n"
    
    if [ -d "hyprwayland-scanner" ]; then
        rm -rf hyprwayland-scanner
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/hyprwayland-scanner.git
        cd hyprwayland-scanner
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        cmake --build build -j$(nproc)
        sudo cmake --install build
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} hyprwayland-scanner built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build hyprwayland-scanner. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build hyprutils from source
build_hyprutils() {
    printf "\n${INFO} Building ${SKY_BLUE}hyprutils${RESET} from source...\n"
    
    if [ -d "hyprutils" ]; then
        rm -rf hyprutils
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/hyprutils.git
        cd hyprutils
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        cmake --build build -j$(nproc)
        sudo cmake --install build
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} hyprutils built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build hyprutils. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build hyprlang from source  
build_hyprlang() {
    printf "\n${INFO} Building ${SKY_BLUE}hyprlang${RESET} from source...\n"
    
    if [ -d "hyprlang" ]; then
        rm -rf hyprlang
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/hyprlang.git
        cd hyprlang
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        cmake --build build -j$(nproc)
        sudo cmake --install build
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} hyprlang built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build hyprlang. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build hyprcursor from source
build_hyprcursor() {
    printf "\n${INFO} Building ${SKY_BLUE}hyprcursor${RESET} from source...\n"
    
    if [ -d "hyprcursor" ]; then
        rm -rf hyprcursor
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/hyprcursor.git
        cd hyprcursor
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        cmake --build build -j$(nproc)
        sudo cmake --install build
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} hyprcursor built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build hyprcursor. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build aquamarine from source
build_aquamarine() {
    printf "\n${INFO} Building ${SKY_BLUE}aquamarine${RESET} from source...\n"
    
    if [ -d "aquamarine" ]; then
        rm -rf aquamarine
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/aquamarine.git
        cd aquamarine
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        cmake --build build -j$(nproc)
        sudo cmake --install build
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} aquamarine built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build aquamarine. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build hyprgraphics from source
build_hyprgraphics() {
    printf "\n${INFO} Building ${SKY_BLUE}hyprgraphics${RESET} from source...\n"
    
    if [ -d "hyprgraphics" ]; then
        rm -rf hyprgraphics
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/hyprgraphics.git
        cd hyprgraphics
        cmake -DCMAKE_INSTALL_PREFIX=/usr/local -B build
        cmake --build build -j$(nproc)
        sudo cmake --install build
        sudo ldconfig
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} hyprgraphics built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build hyprgraphics. Check $LOG for details.\n"
        return 1
    fi
}

# Build in dependency order
build_hyprwayland_scanner
build_hyprutils
build_hyprlang
build_hyprcursor
build_aquamarine
build_hyprgraphics

printf "\n${OK} All Hypr dependencies built successfully from source!\n"
printf "\n%.0s" {1..2}