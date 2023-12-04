#!/bin/bash

rofi=(
  bison
  flex
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
LOG="install-$(date +%d-%H%M%S)_rofi_wayland.log"

# uninstall other rofi
printf "${YELLOW} Checking for other rofi packages and remove if any..${RESET}\n"
if sudo dpkg -l | grep -q -w "rofi"; then
  printf "${YELLOW} rofi detected.. uninstalling...${RESET}\n"
    for rofi in rofi; do
    sudo apt-get autoremove -y "rofi" 2>/dev/null | tee -a "$LOG" || true
    done
fi

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

# Installation of main components
printf "\n%s - Installing rofi-wayland dependencies.... \n" "${NOTE}"

for PKG1 in "${rofi[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed, please check the install.log"
    exit 1
  fi
done

printf "\n\n\n"

# Clone and build rofi - wayland
printf "${NOTE} Installing rofi-wayland...\n"

# Check if rofi folder exists and remove it
if [ -d "rofi" ]; then
  printf "${NOTE} Removing existing rofi folder...\n"
  rm -rf "rofi" 2>&1 | tee -a "$LOG"
fi

if git clone https://github.com/lbonn/rofi.git 2>&1 | tee -a "$LOG"; then
  cd "rofi" || exit 1
  if meson setup build && ninja -C build; then
    if sudo ninja -C build install 2>&1 | tee -a "$LOG"; then
      printf "${OK} rofi-wayland installed successfully.\n"
      # Return to the previous directory
      cd ..
    else
      echo -e "${ERROR} Installation failed for rofi-wayland."
    fi
  else
    echo -e "${ERROR} Meson setup or ninja build failed for rofi-wayland."
  fi
else
  echo -e "${ERROR} Download failed for rofi-wayland."
fi

clear