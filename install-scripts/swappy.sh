#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# swappy - for screenshot) #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swappy2.log"
MLOG="install-$(date +%d-%H%M%S)_swappy.log"

printf "${NOTE} Installing swappy..\n"

# Check if swappy folder exists
if [ -d "swappy" ]; then
  printf "${NOTE} swappy folder exists. Pulling latest changes...\n"
  cd swappy || exit 1
  git pull origin master 2>&1 | tee -a "$MLOG"
else
  printf "${NOTE} Cloning swappy repository...\n"
  if git clone https://github.com/jtheoof/swappy.git; then
    cd swappy || exit 1
  else
    echo -e "${ERROR} Download failed for swappy" 2>&1 | tee -a "$LOG"
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
