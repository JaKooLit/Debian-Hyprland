#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #

#specific branch or release
dots_tag="Deb-Untu-Dots"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Check if Hyprland-Dots exists
printf "${NOTE} Cloning and Installing ${SKY_BLUE}KooL's Hyprland Dots for Debian${RESET}....\n"

# Check if Hyprland-Dots exists
if [ -d Hyprland-Dots-Debian ]; then
  cd Hyprland-Dots-Debian
  git stash
  git pull
  git stash apply
  chmod +x copy.sh
  ./copy.sh 
else
  if git clone --depth 1 -b $dots_tag https://github.com/JaKooLit/Hyprland-Dots Hyprland-Dots-Debian; then
    cd Hyprland-Dots-Debian || exit 1
    chmod +x copy.sh
    ./copy.sh 
  else
    echo -e "$ERROR Can't download ${YELLOW}KooL's Hyprland-Dots-Debian${RESET}"
  fi
fi

clear
