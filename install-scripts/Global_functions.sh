#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Global Functions for Scripts #

set -e

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Function that would show a progress
show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○" "○●○○○○" "○○●○○○" "○○○●○○" "○○○○●○" "○○○○○●" \
                      "○○○○●○" "○○○●○○" "○○●○○○" "○●○○○○")  # Growing & Shrinking Dots
    local i=0

    tput civis  # Hide cursor
    printf "\r${NOTE} Installing ${YELLOW}%s${RESET} ..." "$package_name"

    while ps -p $pid &> /dev/null; do
        printf "\r${NOTE} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
        i=$(( (i + 1) % 10 ))  
        sleep 0.3  
    done

    printf "\r${NOTE} Installing ${YELLOW}%s${RESET} ... Done!%-20s\n" "$package_name" ""
    tput cnorm  
}


# Function for re-installing packages with a progress bar
re_install_package() {
    echo -e "${NOTE} Force installing ${YELLOW}$1${RESET} ..."
    
    # Run the reinstall command in the background
    (
      stdbuf -oL sudo apt-get install --reinstall -y "$1" 2>&1
    ) >> "$LOG" 2>&1 &
    PID=$!
    show_progress $PID "$1" 
    
    # Double check if the package was re-installed successfully
    if dpkg -l | grep -q -w "$1"; then
        echo -e "\e[1A\e[K${OK} Package ${YELLOW}$1${RESET} has been successfully re-installed!"
    else
        # Package was not found, installation failed
        echo -e "${ERROR} $1 failed to re-install. Please check the install.log. You may need to install it manually. Sorry, I have tried :("
        exit 1
    fi
}

# Function for re-installing packages
re_install_package() {
    echo -e "${NOTE} Force installing ${YELLOW}$1${RESET} ..."
    
    # Try to reinstall the package
    if sudo apt-get install --reinstall -y "$1" 2>&1 | tee -a "$LOG"; then
        # Check if the package was installed successfully
        if dpkg -l | grep -q -w "$1"; then
            echo -e "\e[1A\e[K${OK} Package ${YELLOW}$1${RESET} has been successfully re-installed!"
        else
            # Package was not found, installation failed
            echo -e "${ERROR} $1 failed to install. Please check the install.log. You may need to install it manually. Sorry, I have tried :("
            exit 1
        fi
    else
        # Installation command failed
        echo -e "${ERROR} Failed to reinstall $1. Please check the install.log. You may need to install it manually. Sorry, I have tried :("
        exit 1
    fi
}

uninstall_package() {
  # Check if package is installed
  if sudo dpkg -l | grep -q -w "^ii  $1" ; then
    # Package is installed, attempt to uninstall
    echo -e "${NOTE} Uninstalling ${YELLOW}$1${RESET} ..."

    # Attempt to uninstall the package and its configuration files
    sudo apt-get autoremove -y "$1" >> "$LOG" 2>&1

    # Check if the package is still installed after removal attempt
    if ! dpkg -l | grep -q -w "^ii  $1" ; then
      echo -e "\e[1A\e[K${OK} ${MAGENTA}$1${RESET} was uninstalled."
    else
      echo -e "\e[1A\e[K${ERROR} $1 failed to uninstall. Please check the uninstall.log."
      exit 1
    fi
  fi
}
