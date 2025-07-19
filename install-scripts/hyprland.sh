#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package#

#specific branch or release
hyprland_tag="v0.49.0"

hyprland=(
	libxcb-errors-dev
	libre2-dev
	libglaze-dev
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland2.log"

# Installation of dependencies
printf "\n%s - Installing hyprland additional dependencies.... \n" "${NOTE}"

for PKG1 in "${hyprland[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "\n%.0s" {1..1}

# Installation of dependencies (glaze)
printf "\n%s - Installing Hyprland additional dependencies (glaze).... \n" "${NOTE}"

# Check if /usr/include/glaze exists
if [ ! -d /usr/include/glaze ]; then
    echo "${INFO} ${YELLOW}Glaze${RESET} is not installed. Installing ${YELLOW}glaze from assets${RESET} ..."
    sudo dpkg -i assets/libglaze-dev_4.4.3-1_all.deb 2>&1 | tee -a "$LOG"
    sudo apt install -f -y 2>&1 | tee -a "$LOG"
    echo "${INFO} ${YELLOW}libglaze-dev from assets${RESET} installed."
fi


printf "\n%.0s" {1..1}

# Clone, build, and install Hyprland using Cmake
printf "${NOTE} Cloning and Installing ${YELLOW}Hyprland $hyprland_tag${RESET} ...\n"

# Check if Hyprland folder exists and remove it
if [ -d "Hyprland" ]; then
  printf "${NOTE} Removing existing Hyprland folder...\n"
  rm -rf "Hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b $hyprland_tag "https://github.com/hyprwm/Hyprland"; then
  cd "Hyprland" || exit 1
  make all
  if sudo make install 2>&1 | tee -a "$MLOG"; then
    printf "${OK} ${MAGENTA}Hyprland $hyprland_tag${RESET}  installed successfully.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for ${YELLOW}Hyprland $hyprland_tag${RESET}" 2>&1 | tee -a "$MLOG"
  fi
  mv $MLOG ../Install-Logs/ || true   
  cd ..
else
  echo -e "${ERROR} Download failed for ${YELLOW}Hyprland $hyprland_tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}