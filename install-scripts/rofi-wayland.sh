#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Rofi-Wayland) #

rofi=(
  bison
  flex
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_rofi_wayland.log"
MLOG="install-$(date +%d-%H%M%S)_rofi_wayland2.log"

# uninstall other rofi
for PKG in "rofi" "bison"; do
  uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG uninstallation had failed, please check the log"
    exit 1
  fi
done

sleep 1
printf "\n"
# Installation of main components
printf "\n%s - Installing rofi-wayland dependencies.... \n" "${NOTE}"

printf "${NOTE} Force installing packages...\n"
 for FORCE in "${rofi[@]}"; do
   sudo apt-get --reinstall install -y "$FORCE" 2>&1 | tee -a "$LOG"
   [ $? -ne 0 ] && { echo -e "\e[1A\e[K${ERROR} - $FORCE install had failed, please check the install.log"; exit 1; }
  done

printf "\n\n"

# Clone and build rofi - wayland
printf "${NOTE} Installing rofi-wayland...\n"

printf "${NOTE} Installing rofi-wayland\n"

# Check if rofi folder exists
if [ -d "rofi" ]; then
  printf "${NOTE} rofi folder exists. Pulling latest changes...\n"
  cd rofi || exit 1
  git pull origin master 2>&1 | tee -a "$MLOG"
else
  printf "${NOTE} Cloning rofi repository...\n"
  if git clone https://github.com/lbonn/rofi.git; then
    cd rofi || exit 1
  else
    echo -e "${ERROR} Download failed for rofi-wayland." 2>&1 | tee -a "$LOG"
    exit 1
  fi
fi

# Proceed with the installation steps
if meson setup build && ninja -C build; then
  if sudo ninja -C build install 2>&1 | tee -a "$MLOG"; then
    printf "${OK} rofi-wayland installed successfully.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for rofi-wayland." 2>&1 | tee -a "$MLOG"
  fi
else
  echo -e "${ERROR} Meson setup or ninja build failed for rofi-wayland." 2>&1 | tee -a "$MLOG"
fi

# Move logs to Install-Logs directory
mv "$MLOG" ../Install-Logs/ || true
cd .. || exit 1

clear

