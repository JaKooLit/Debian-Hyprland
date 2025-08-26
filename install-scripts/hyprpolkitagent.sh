#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hypr Ecosystem #
# hyprpolkitagent #

polkitagent=(
	libpolkit-agent-1-dev
	libpolkit-qt6-1-dev
  qml6-module-qtquick-layouts
  qt6-tools-dev
  qt6-tools-dev-tools
  qt6-charts-dev
)

#specific branch or release
tag="v0.1.3"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprpolkitagent.log"
MLOG="install-$(date +%d-%H%M%S)_hyprpolkitagent.log"

# Installation of dependencies
printf "\n%s - Installing hyprpolkitagent dependencies.... \n" "${NOTE}"

for PKG1 in "${polkitagent[@]}"; do
  re_install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Check if hyprpolkitagent folder exists and remove it
if [ -d "hyprpolkitagent" ]; then
    printf "${NOTE} Removing existing hyprpolkitagent folder...\n"
    rm -rf "hyprpolkitagent"
fi

# Clone and build 
printf "${NOTE} Installing hyprpolkitagent...\n"
if git clone --recursive -b $tag https://github.com/hyprwm/hyprpolkitagent.git; then
    cd hyprpolkitagent || exit 1
	cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -S . -B ./build
	cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} hyprpolkitagent installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for hyprpolkitagent." 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for hyprpolkitagent." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}


