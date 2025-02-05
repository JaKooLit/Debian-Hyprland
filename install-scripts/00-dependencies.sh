#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# main dependencies #

# packages neeeded
dependencies=(
    build-essential
    cmake
    cmake-extras
    curl
    gawk
    gettext
    git
    glslang-tools
    gobject-introspection
    golang
    hwdata
    jq
    libmpdclient-dev
    libnl-3-dev
    libasound2-dev
    libstartup-notification0-dev
    libwayland-client++1
    libwayland-dev
    libcairo-5c-dev
    libcairo2-dev
    libsdbus-c++-bin    
    libegl-dev
    libegl1-mesa-dev  
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
    #vulkan-validationlayers
    vulkan-utility-libraries-dev
    wayland-protocols
    xdg-desktop-portal
    xwayland
)

build_dep=(
  wlroots
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_dependencies.log"

# Installation of main dependencies
printf "\n%s - Installing ${SKY_BLUE}main dependencies....${RESET} \n" "${NOTE}"

# modernized sources
sudo apt modernize-sources -y

for PKG in "${dependencies[@]}"; do
  install_package "$PKG" "$LOG"
done

printf "\n%.0s" {1..1}

for PKG1 in "${build_dep[@]}"; do
  build_dep "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}
