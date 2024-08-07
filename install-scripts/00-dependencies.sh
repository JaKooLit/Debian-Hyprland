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
    libgulkan-dev
    libinih-dev
    libinput-dev
    libjbig-dev
    libjpeg-dev
    libjpeg62-dev
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
    libtomlplusplus-dev
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
    make
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
    scdoc
    seatd
    spirv-tools
    vulkan-validationlayers
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
printf "\n%s - Installing main dependencies.... \n" "${NOTE}"

for PKG1 in "${dependencies[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Remove Ubuntu default Rust Install
# Get the list of installed Rust packages
rust_packages=$(apt list --installed 2>/dev/null | grep rust | awk -F/ '{print $1}')

# Check if there are any Rust packages to remove
if [ -z "$rust_packages" ]; then
    echo "No Rust packages found."
else
    # Display the packages to be removed
    echo "Removing the following Rust packages:"
    echo "$rust_packages"

    # Remove the Rust packages
    sudo apt remove --purge -y $rust_packages
    if [ $? -ne 0 ]; then
        echo "Error removing Rust packages."
        exit 1
    fi

    # Clean up unused dependencies
    sudo apt autoremove -y
    if [ $? -ne 0 ]; then
        echo "Error during autoremove."
        exit 1
    fi

    # Remove Rust-related configuration files if needed
    echo "Removing Rust environment configurations..."
    if [ -f "$HOME/.cargo/env" ]; then
        echo "Removing $HOME/.cargo/env..."
        rm -f "$HOME/.cargo/env"
    fi

    if [ -d "$HOME/.cargo" ]; then
        echo "Removing $HOME/.cargo..."
        rm -rf "$HOME/.cargo"
    fi

    if [ -d "$HOME/.rustup" ]; then
        echo "Removing $HOME/.rustup..."
        rm -rf "$HOME/.rustup"
    fi
fi

# Install Rust 
# Enable ubuntu source repositories
FILE="/etc/apt/sources.list.d/ubuntu.sources"
if [ -f "$FILE" ]; then
    sudo sed -i 's/Types: deb/Types: deb deb-src/' "$FILE"
else
    echo "File /etc/apt/sources.list.d/ubuntu.sources doesn't exist."
    exit 1
fi

# Update package lists
sudo apt update

# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env

# Ensure the Rust environment source line is in .bashrc
if ! grep -q 'source $HOME/.cargo/env' ~/.bashrc; then
    {
        echo
        echo "# Sourcing Rust"
        echo 'source $HOME/.cargo/env'
    } >> ~/.bashrc
fi

# Install dependencies for wlroots
sudo apt build-dep -y wlroots
export PATH=$PATH:/usr/local/go/bin

clear
