#!/bin/bash
# https://github.com/JaKooLit

# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in debian repo

sddm1=(
  sddm
)

sddm2=(
  qml-module-qtgraphicaleffects
  qml-module-qtquick-controls 
  qml-module-qtquick-controls2
  qml-module-qtquick-extras 
  qml-module-qtquick-layouts
)

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
LOG="install-$(date +%d-%H%M%S)_sddm.log"

set -e

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

# Install SDDM and Tokyo-Night theme
printf "\n%s - Installing sddm.... \n" "${NOTE}"
for PKG1 in "${sddm1[@]}" ; do
  sudo apt-get install --no-install-recommends -y "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 install had failed, please check the install.log"
    exit 1
  fi
done

# Installation of additional sddm stuff
printf "\n%s - Installing sddm additional stuff.... \n" "${NOTE}"
for PKG2 in "${sddm2[@]}"; do
  install_package "$PKG2" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG2 install had failed, please check the install.log"
    exit 1
  fi
done

# Check if other login managers are installed and disabling their service before enabling sddm
for login_manager in lightdm gdm lxdm lxdm-gtk3; do
  if sudo apt-get list installed "$login_manager" &>> /dev/null; then
    echo "Disabling $login_manager..."
    sudo systemctl disable "$login_manager" 2>&1 | tee -a "$LOG"
  fi
done

printf " Activating sddm service........\n"
sudo systemctl enable sddm

# Set up SDDM
echo -e "${NOTE} Setting up the login screen."
sddm_conf_dir=/etc/sddm.conf.d
[ ! -d "$sddm_conf_dir" ] && { printf "$CAT - $sddm_conf_dir not found, creating...\n"; sudo mkdir -p "$sddm_conf_dir" 2>&1 | tee -a "$LOG"; }

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && { printf "$CAT - $wayland_sessions_dir not found, creating...\n"; sudo mkdir -p "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"; }
sudo cp assets/hyprland.desktop "$wayland_sessions_dir/" 2>&1 | tee -a "$LOG"
    
# Tokyo-night SDDM-themes
printf "\n%s - Installing Tokyo-Night SDDM Theme\n" "${NOTE}"
git clone https://github.com/rototrash/tokyo-night-sddm.git 2>&1 | tee -a "$LOG"
sudo mkdir -p /usr/share/sddm/themes
sudo mv tokyo-night-sddm /usr/share/sddm/themes/
echo -e "[Theme]\nCurrent=tokyo-night-sddm" | sudo tee -a "$sddm_conf_dir/10-theme.conf" 2>&1 | tee -a "$LOG"              		

clear