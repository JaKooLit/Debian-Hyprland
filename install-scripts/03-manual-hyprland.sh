#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Manual Hyprland Build - Build Hyprland itself from source #

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_manual-hyprland.log"

printf "\n${NOTE} Building ${SKY_BLUE}Hyprland from source${RESET}...\n"

# Create build directory
BUILD_DIR="$HOME/hypr-source-builds"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Function to build Hyprland from source
build_hyprland() {
    printf "\n${INFO} Building ${SKY_BLUE}Hyprland${RESET} from source...\n"
    
    if [ -d "Hyprland" ]; then
        rm -rf Hyprland
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/Hyprland.git
        cd Hyprland
        
        # Use the latest stable release
        git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
        
        # Update PKG_CONFIG_PATH to find our manually built dependencies
        export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH"
        export LD_LIBRARY_PATH="/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH"
        
        # Build using CMake (recommended method)
        make all
        sudo make install
        
        # Copy desktop file for display managers
        sudo cp ./example/hyprland.desktop /usr/share/wayland-sessions/
        
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} Hyprland built and installed successfully!\n"
        printf "${NOTE} Hyprland desktop file installed to /usr/share/wayland-sessions/\n"
    else
        printf "${ERROR} Failed to build Hyprland. Check $LOG for details.\n"
        return 1
    fi
}

# Function to build xdg-desktop-portal-hyprland from source
build_xdph() {
    printf "\n${INFO} Building ${SKY_BLUE}xdg-desktop-portal-hyprland${RESET} from source...\n"
    
    if [ -d "xdg-desktop-portal-hyprland" ]; then
        rm -rf xdg-desktop-portal-hyprland
    fi
    
    (
        git clone --recursive https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
        cd xdg-desktop-portal-hyprland
        
        # Update PKG_CONFIG_PATH for our dependencies
        export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH"
        
        meson setup build --prefix=/usr/local --buildtype=release
        ninja -C build
        sudo ninja -C build install
        
    ) >> "$LOG" 2>&1
    
    if [ $? -eq 0 ]; then
        printf "${OK} xdg-desktop-portal-hyprland built and installed successfully!\n"
    else
        printf "${ERROR} Failed to build xdg-desktop-portal-hyprland. Check $LOG for details.\n"
        return 1
    fi
}

# Check compiler version
printf "\n${INFO} Checking compiler requirements...\n"
gcc_version=$(gcc -dumpversion | cut -d. -f1)
if [ "$gcc_version" -lt 15 ]; then
    printf "${WARN} GCC version $gcc_version detected. Hyprland requires GCC >= 15 for C++26 support.\n"
    printf "${NOTE} You may need to install a newer GCC version or use Clang >= 19.\n"
fi

# Update PKG_CONFIG_PATH and LD_LIBRARY_PATH for our manually built libraries
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH"

# Add to user's profile for future sessions
if ! grep -q "PKG_CONFIG_PATH.*usr/local" ~/.bashrc; then
    echo 'export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/local/share/pkgconfig:$PKG_CONFIG_PATH"' >> ~/.bashrc
    echo 'export LD_LIBRARY_PATH="/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
    printf "${NOTE} Updated ~/.bashrc with library paths for manually built components.\n"
fi

# Build Hyprland and portal
build_hyprland
build_xdph

# Update dynamic linker cache
sudo ldconfig

printf "\n${OK} Manual Hyprland build completed!\n"
printf "${NOTE} You may need to logout/login or reboot for all changes to take effect.\n"
printf "\n%.0s" {1..2}