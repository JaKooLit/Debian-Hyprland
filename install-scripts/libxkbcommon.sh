#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# libxkbcommon - Required for Hyprland 0.52.1+ #

xkbcommon_deps=(
    meson
    bison
    libwayland-dev
    libxml2-dev
    xutils-dev
    doxygen
)

#specific branch or release
tag="xkbcommon-1.13.0"
# Allow environment override
if [ -n "${LIBXKBCOMMON_TAG:-}" ]; then tag="$LIBXKBCOMMON_TAG"; fi

# Dry-run support
DO_INSTALL=1
if [ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_libxkbcommon.log"
MLOG="install-$(date +%d-%H%M%S)_libxkbcommon2.log"

# Check if we need to upgrade
CURRENT_VERSION=$(pkg-config --modversion xkbcommon 2>/dev/null || echo "0.0.0")
REQUIRED_VERSION="1.9.0"

version_compare() {
    printf '%s\n%s\n' "$1" "$2" | sort -V -C
}

if version_compare "$CURRENT_VERSION" "$REQUIRED_VERSION"; then
    printf "${OK} libxkbcommon $CURRENT_VERSION is already >= $REQUIRED_VERSION\n"
    if [ "$CURRENT_VERSION" = "${tag#xkbcommon-}" ]; then
        printf "${OK} libxkbcommon $tag is already installed, skipping.\n"
        exit 0
    fi
fi

printf "${NOTE} Current libxkbcommon version: $CURRENT_VERSION, required: >= $REQUIRED_VERSION\n"
printf "${NOTE} Installing libxkbcommon $tag ...\n"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}libxkbcommon dependencies${RESET} .... \n" "${INFO}"

for PKG1 in "${xkbcommon_deps[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - ${YELLOW}$PKG1${RESET} Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "\n%.0s" {1..1}

# Check if libxkbcommon directory exists and remove it
if [ -d "libxkbcommon" ]; then
    rm -rf "libxkbcommon"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}libxkbcommon $tag${RESET} ...\n"
if git clone --recursive -b $tag https://github.com/xkbcommon/libxkbcommon.git; then
    cd libxkbcommon || exit 1
    meson setup build \
        -Dprefix=/usr \
        -Dlibdir=/usr/lib/x86_64-linux-gnu \
        -Denable-docs=false \
        -Denable-wayland=true \
        -Denable-x11=true \
        --buildtype=release
    ninja -C build
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo ninja -C build install 2>&1 | tee -a "$MLOG" ; then
            printf "${OK} ${MAGENTA}libxkbcommon $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
            # Update ldconfig
            sudo ldconfig
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}libxkbcommon $tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of libxkbcommon $tag."
    fi
    #moving the addional logs to Install-Logs directory
    [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}libxkbcommon $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
