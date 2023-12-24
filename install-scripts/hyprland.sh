#!/bin/bash

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
LOG="install-$(date +%d-%H%M%S)_hyprland.log"

# Clone, build, and install Hyprland using Cmake
printf "${NOTE} Cloning Hyprland...\n"

# Check if Hyprland folder exists and remove it
if [ -d "Hyprland" ]; then
  printf "${NOTE} Removing existing Hyprland folder...\n"
  rm -rf "Hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b v0.32.3 "https://github.com/hyprwm/Hyprland" 2>&1 | tee -a "$LOG"; then
  cd "Hyprland" || exit 1
  make all 2>&1 | tee -a "$LOG"
  if sudo make install 2>&1 | tee -a "$LOG"; then
    printf "${OK} Hyprland installed successfully.\n"
  else
    echo -e "${ERROR} Installation failed for Hyprland."
  fi  
  cd ..
else
  echo -e "${ERROR} Download failed for Hyprland."
fi

clear

