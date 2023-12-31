#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Swaylock Effects #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swaylock-effects2.log"
MLOG="install-$(date +%d-%H%M%S)_swaylock-effects.log"

printf "${NOTE} Installing swaylock-effects\n"
# Check if swaylock-effects folder exists
if [ -d "swaylock-effects" ]; then
  printf "${NOTE} swaylock-effects folder exists. Pulling latest changes...\n"
  cd swaylock-effects || exit 1
  git pull origin master 2>&1 | tee -a "$MLOG"
else
  printf "${NOTE} Cloning swaylock-effects repository...\n"
  if git clone https://github.com/jirutka/swaylock-effects.git; then
    cd swaylock-effects || exit 1
  else
    echo -e "${ERROR} Download failed for swaylock-effects" 2>&1 | tee -a "$LOG"
    exit 1
  fi
fi

# Proceed with the installation steps
meson build
ninja -C build
sudo ninja -C build install 2>&1 | tee -a "$MLOG"

# Moving logs into main Install-Logs
mv "$MLOG" ../Install-Logs/ || true 
cd - || exit 1

clear