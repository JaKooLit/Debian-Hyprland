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

for PKG1 in "${dependencies[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%.0s" {1..2}
