#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprland-qt-support #


#specific branch or release
lang_tag="v0.1.0"

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland-qt-support.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland-qt-support2.log"

# Installation of dependencies
printf "\n%s - Installing ${YELLOW}hyprland-qt-support dependencies${RESET} .... \n" "${INFO}"

# Check if hyprland-qt-support directory exists and remove it
if [ -d "hyprland-qt-support" ]; then
    rm -rf "hyprland-qt-support"
fi

# Clone and build 
printf "${INFO} Installing ${YELLOW}hyprland-qt-support $lang_tag${RESET} ...\n"
if git clone --recursive -b $lang_tag https://github.com/hyprwm/hyprland-qt-support.git; then
    cd hyprland-qt-support || exit 1
	cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH=/usr -DINSTALL_QML_PREFIX=/usr/lib/x86_64-linux-gnu/qt6/qml -S . -B ./build
    cmake --build ./build --config Release --target all -j`nproc 2>/dev/null || getconf _NPROCESSORS_CONF`
    if sudo cmake --install ./build 2>&1 | tee -a "$MLOG" ; then
        printf "${OK} ${MAGENTA}hyprland-qt-support $lang_tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
        echo -e "${ERROR} Installation failed for ${YELLOW}hyprland-qt-support $lang_tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi
    #moving the addional logs to Install-Logs directory
    mv $MLOG ../Install-Logs/ || true 
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprland-qt-support $lang_tag${RESET}" 2>&1 | tee -a "$LOG"
fi
rm -rf "hyprland-qt-support" # Cleanup
printf "\n%.0s" {1..2}
