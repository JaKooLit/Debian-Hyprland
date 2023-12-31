#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SWWW - Wallpaper Utility #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_swww2.log"
MLOG="install-$(date +%d-%H%M%S)_swww.log"

printf "${NOTE} Installing swww\n"

# Check if swww folder exists
if [ -d "swww" ]; then
  printf "${NOTE} swww folder exists. Pulling latest changes...\n"
  cd swww || exit 1
  git pull origin main 2>&1 | tee -a "$MLOG"
else
  printf "${NOTE} Cloning swww repository...\n"
  if git clone https://github.com/Horus645/swww.git; then
    cd swww || exit 1
  else
    echo -e "${ERROR} Download failed for swww" 2>&1 | tee -a "$LOG"
    exit 1
  fi
fi

# Proceed with the rest of the installation steps
source "$HOME/.cargo/env"
cargo build --release 2>&1 | tee -a "$MLOG"
# Copy binaries to /usr/bin/
sudo cp target/release/swww /usr/bin/ 2>&1 | tee -a "$MLOG"
sudo cp target/release/swww-daemon /usr/bin/ 2>&1 | tee -a "$MLOG"

# Copy bash completions
sudo mkdir -p /usr/share/bash-completion/completions 2>&1 | tee -a "$MLOG"
sudo cp completions/swww.bash /usr/share/bash-completion/completions/swww 2>&1 | tee -a "$MLOG"

# Copy zsh completions
sudo mkdir -p /usr/share/zsh/site-functions 2>&1 | tee -a "$MLOG"
sudo cp completions/_swww /usr/share/zsh/site-functions/_swww 2>&1 | tee -a "$MLOG"

# Moving logs into main Install-Logs
mv "$MLOG" ../Install-Logs/ || true 
cd - || exit 1

clear
