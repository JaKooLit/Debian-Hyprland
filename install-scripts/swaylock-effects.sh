#!/bin/bash

############## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU'RE DOING! ##############

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
LOG="install-$(date +'%d-%H%M%S')_swaylock-effects.log"

printf "${NOTE} Installing swaylock-effects\n"

if git clone https://github.com/mortie/swaylock-effects.git; then
  cd swaylock-effects || exit 1
  meson build
  ninja -C build
  sudo ninja -C build install 2>&1 | tee -a "$LOG"
  # Return to the previous directory
  cd - || exit 1
else
  echo -e "${ERROR} Download failed for swaylock-effects" 2>&1 | tee -a "$LOG"
fi

clear
