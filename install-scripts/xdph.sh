#!/bin/bash


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
LOG="install-$(date +%d-%H%M%S)_xdph.log"

# Clone and build xdg-desktop-portal-hyprland
printf "${NOTE} Installing xdg-desktop-portal-hyprland...\n"
if git clone https://github.com/hyprwm/xdg-desktop-portal-hyprland.git 2>&1 | tee -a "$LOG"; then
  cd xdg-desktop-portal-hyprland || exit 1
  cd subprojects
  git clone https://github.com/hyprwm/hyprland-protocols.git
  git clone https://github.com/Kistler-Group/sdbus-cpp.git
  cd ..
  make all
  if sudo make install 2>&1 | tee -a "$LOG"; then
    printf "${OK} xdg-desktop-portal-hyprland installed successfully.\n"
    # Return to the previous directory
    cd ..
  else
    echo -e "${ERROR} Installation failed for xdg-desktop-portal-hyprland."
  fi
else
  echo -e "${ERROR} Download failed for xdg-desktop-portal-hyprland."
fi

printf "\n"
printf "\n"
printf "\n"
  # Clean out other portals
  printf "${NOTE} Clearing any other xdg-desktop-portal implementations...\n"
  # Check if packages are installed and uninstall if present
  if sudo apt list installed xdg-desktop-portal-gnome &>> /dev/null; then
    echo "Removing xdg-desktop-portal-gnome..."
    sudo apt remove -y xdg-desktop-portal-gnome 2>&1 | tee -a "$LOG"
  fi
  if sudo apt list installed xdg-desktop-portal-wlr &>> /dev/null; then
    echo "Removing xdg-desktop-portal-wlr..."
    sudo apt remove -y xdg-desktop-portal-wlr 2>&1 | tee -a "$LOG"
  fi
  if sudo apt list installed xdg-desktop-portal-lxqt &>> /dev/null; then
    echo "Removing xdg-desktop-portal-lxqt..."
    sudo apt remove -y xdg-desktop-portal-lxqt 2>&1 | tee -a "$LOG"
  fi

sed -i '17s/#//' config/hypr/configs/Execs.conf

clear