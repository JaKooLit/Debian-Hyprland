#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# main dependencies #
# 22 Aug 2024 - NOTE will trim this more down

# packages neeeded
dependencies=(
    build-essential
    cmake
    cmake-extras
    curl
    findutils
    gawk
    gettext
    git
    glslang-tools
    gobject-introspection
    golang
    hwdata
    jq
    libegl-dev
    libegl1-mesa-dev
    meson
    ninja-build
    openssl
    psmisc
    python3-mako
    python3-markdown
    python3-markupsafe
    python3-yaml
    python3-pyquery
    qt6-base-dev
    spirv-tools
    unzip
    vulkan-validationlayers
    vulkan-utility-libraries-dev
    wayland-protocols
    xdg-desktop-portal
    xwayland
)

# hyprland dependencies
hyprland_dep=(
    bc
    binutils
    libc6
    libcairo2-dev
    libdisplay-info2
    libdrm2
    libjpeg-dev
    libjxl-dev
    libmagic-dev
    libpixman-1-dev
    libpugixml-dev
    libre2-dev
    librsvg2-dev
    libspng-dev
    libtomlplusplus-dev
    libwebp-dev
    libzip-dev
    libpam0g-dev
    libxcursor-dev
    qt6-declarative-dev
    qt6-base-private-dev
    qt6-wayland-dev
    qt6-wayland-private-dev
)

build_dep=(
    wlroots
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source $SCRIPT_DIR/Global_functions.sh"
    exit 1
}

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_dependencies.log"

# Installation of main dependencies
echo -e "\n${NOTE} - Installing ${SKY_BLUE}main dependencies....${RESET}"

for PKG1 in "${dependencies[@]}" "${hyprland_dep[@]}"; do
    install_package "$PKG1" "$LOG"
done

newlines 1

for PKG1 in "${build_dep[@]}"; do
    build_dep "$PKG1" "$LOG"
done

newlines 2
