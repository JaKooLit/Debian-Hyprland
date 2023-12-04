#!/bin/bash

# https://github.com/JaKooLit

# WARNING! If you remove packages here, Hyprland may not work properly.

# packages neeeded
dependencies=(
    build-essential
    cmake
    cmake-extras
    curl
    gettext
    gir1.2-graphene-1.0
    git
    glslang-tools
    gobject-introspection
    golang
    hwdata
    jq
    libavcodec-dev
    libavformat-dev
    libavutil-dev
    libcairo2-dev
    libdeflate-dev
    libdisplay-info-dev
    libdrm-dev
    libegl1-mesa-dev
    libgbm-dev
    libgdk-pixbuf-2.0-dev
    libgdk-pixbuf2.0-bin
    libgirepository1.0-dev
    libgl1-mesa-dev
    libgraphene-1.0-0
    libgraphene-1.0-dev
    libgtk-3-dev
    libgulkan-0.15-0
    libgulkan-dev
    libinih-dev
    libinput-dev
    libjbig-dev
    libjpeg-dev
    libjpeg62-turbo-dev
    liblerc-dev
    libliftoff-dev
    liblzma-dev
    libnotify-bin
    libpam0g-dev
    libpango1.0-dev
    libpipewire-0.3-dev
    libqt6svg6
    libseat-dev
    libstartup-notification0-dev
    libswresample-dev
    libsystemd-dev
    libtiff-dev
    libtiffxx6
    libudev-dev
    libvkfft-dev
    libvulkan-dev
    libvulkan-volk-dev
    libwayland-dev
    libwebp-dev
    libxcb-composite0-dev
    libxcb-cursor-dev
    libxcb-dri3-dev
    libxcb-ewmh-dev
    libxcb-icccm4-dev
    libxcb-present-dev
    libxcb-render-util0-dev
    libxcb-res0-dev
    libxcb-util-dev
    libxcb-xinerama0-dev
    libxcb-xinput-dev
    libxcb-xkb-dev
    libxkbcommon-dev
    libxkbcommon-x11-dev
    libxkbregistry-dev
    libxml2-dev
    libxxhash-dev
    meson
    ninja-build
    openssl
    psmisc
    python3-mako
    python3-markdown
    python3-markupsafe
    python3-yaml
    qt6-base-dev
    scdoc
    seatd
    spirv-tools
    vulkan-validationlayers
    vulkan-validationlayers-dev
    wayland-protocols
    xdg-desktop-portal
    xwayland
)

############## WARNING DO NOT EDIT BEYOND THIS LINE if you dont know what you are doing! ######################################
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S)_dependencies.log"

set -e

# Function for installing packages
install_package() {
  # Checking if package is already installed
  if sudo dpkg -l | grep -q -w "$1" ; then
    echo -e "${OK} $1 is already installed. Skipping..."
  else
    # Package not installed
    echo -e "${NOTE} Installing $1 ..."
    sudo apt-get install -y "$1" 2>&1 | tee -a "$LOG"
    # Making sure the package is installed
    if sudo dpkg -l | grep -q -w "$1" ; then
      echo -e "\e[1A\e[K${OK} $1 was installed."
    else
      # Something is missing, exiting to review the log
      echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log. You may need to install manually! Sorry, I have tried :("
      exit 1
    fi
  fi
}


# Installation of main dependencies
printf "\n%s - Installing main dependencies.... \n" "${NOTE}"

for PKG1 in "${dependencies[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed, please check the install.log"
    exit 1
  fi
done

# Install dependencies for wlroots
sudo apt build-dep wlroots
export PATH=$PATH:/usr/local/go/bin

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

clear
