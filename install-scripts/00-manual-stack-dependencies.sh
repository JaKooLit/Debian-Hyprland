#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Manual Stack Dependencies - Build entire Hyprland stack from source #
# Based on Hyprland wiki recommendations for building manually #

# Base build dependencies needed for manual compilation
base_dependencies=(
    build-essential
    cmake
    cmake-extras
    curl
    findutils
    gawk
    gettext
    gettext-base
    git
    glslang-tools
    gobject-introspection
    hwdata
    jq
    meson
    ninja-build
    openssl
    psmisc
    python3-mako
    python3-markdown
    python3-markupsafe
    python3-yaml
    python3-pyquery
    spirv-tools
    unzip
    vulkan-validationlayers
    vulkan-utility-libraries-dev
    xdg-desktop-portal
    xwayland
    # Additional dependencies for manual builds
    libfontconfig-dev
    libffi-dev
    libxml2-dev
    libdrm-dev
    libxkbcommon-x11-dev
    libxkbregistry-dev
    libxkbcommon-dev
    libpixman-1-dev
    libudev-dev
    libseat-dev
    seatd
    libxcb-dri3-dev
    libegl-dev
    libgles2-mesa-dev
    libegl1-mesa-dev
    libinput-bin
    libinput-dev
    libxcb-composite0-dev
    libavutil-dev
    libavcodec-dev
    libavformat-dev
    libxcb-ewmh2
    libxcb-ewmh-dev
    libxcb-present-dev
    libxcb-icccm4-dev
    libxcb-render-util0-dev
    libxcb-res0-dev
    libxcb-xinput-dev
    libtoml11-dev
    libre2-dev
    libpam0g-dev
    fontconfig
    bc
    binutils
    libc6
    libcairo2
)

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_manual-stack-dependencies.log"

# Installation of base dependencies for manual builds
printf "\n%s - Installing ${SKY_BLUE}base dependencies for manual stack build....${RESET} \n" "${NOTE}"

for PKG1 in "${base_dependencies[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n${OK} Base dependencies for manual stack build installed successfully!\n"
printf "\n%.0s" {1..2}