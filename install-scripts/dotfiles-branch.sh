#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #

#specific branch or release
dots_tag="Deb-Untu-Dots"

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

# Check if Hyprland-Dots exists
printf "${NOTE} Cloning and Installing ${SKY_BLUE}KooL's Hyprland Dots for Debian${RESET}....\n"

# Check if Hyprland-Dots exists
if [ -d Hyprland-Dots-Debian ]; then
  cd Hyprland-Dots-Debian
  git stash && git pull
  chmod +x copy.sh
  ./copy.sh 
else
  if git clone --depth=1 -b $dots_tag https://github.com/JaKooLit/Hyprland-Dots Hyprland-Dots-Debian; then
    cd Hyprland-Dots-Debian || exit 1
    chmod +x copy.sh
    ./copy.sh 
  else
    echo -e "$ERROR Can't download ${YELLOW}KooL's Hyprland-Dots-Debian${RESET}"
  fi
fi

printf "\n%.0s" {1..2}
