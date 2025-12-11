#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hypland-guiutils #

guiutils=(
	libqt6core5compat6
    qt6-base-dev
	qt6-wayland-dev
    qt6-wayland
	qt6-declarative-dev
	qml6-module-qtcore
	qt6-3d-dev
	qt6-5compat-dev
    libqt6waylandclient6
    qml6-module-qtwayland-client-texturesharing
)

#specific branch or release
tag="v0.2.0"
# Allow environment override
if [ -n "${HYPRLAND_GUIUTILS_TAG:-}" ]; then tag="$HYPRLAND_GUIUTILS_TAG"; fi

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland-guiutils.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland-guiutils2.log"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprland-guiutils dependencies${RESET} .... \n" "${INFO}"

for PKG1 in "${guiutils[@]}"; do
  re_install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - ${YELLOW}$PKG1${RESET} Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "\n%.0s" {1..1}

# Check if hyprland-guiutils directory exists and remove it
if [ -d "hyprland-guiutils" ]; then
    rm -rf "hyprland-guiutils"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}hyprland-guiutils $tag${RESET} ...\n"
if git clone --recursive -b $tag https://github.com/hyprwm/hyprland-guiutils.git; then
    cd hyprland-guiutils || exit 1
	cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
	cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
            printf "${OK} ${MAGENTA}hyprland-guiutils $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}hyprland-guiutils $tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of hyprland-guiutils $tag."
    fi
    #moving the addional logs to Install-Logs directory
    [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprland-guiutils $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
