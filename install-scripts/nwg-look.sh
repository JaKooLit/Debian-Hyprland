#!/bin/bash

nwg_look=(
  golang
  libgtk-3-dev
  libcairo2-dev
  libglib2.0-bin
)

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
LOG="install-$(date +'%d-%H%M%S')_nwg-look.log"

# Function for installing packages on Debian/Ubuntu
install_package() {
  # Checking if package is already installed
  if dpkg -l | grep -q -w "$1"; then
    echo -e "${OK} $1 is already installed. Skipping..."
  else
    # Package not installed
    echo -e "${NOTE} Installing $1 ..."
    sudo apt-get install -y "$1" >> "$LOG" 2>&1
    # Check if the package was installed successfully
    if dpkg -l | grep -q -w "$1"; then
      echo -e "\e[1A\e[K${OK} $1 was installed."
    else
      # Something is missing, exiting to review the log
      echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log. You may need to install manually! Sorry, I have tried :("
      exit 1
    fi
  fi
}

for package in "${nwg_look[@]}"; do
  install_package "$package" || exit 1
done

printf "${NOTE} Installing nwg-look\n"
if git clone https://github.com/nwg-piotr/nwg-look.git; then
  cd nwg-look || exit 1
  make build
  sudo make install
  cd ..
else
  echo -e "${ERROR} Download failed for nwg-look."
  exit 1
fi

clear
