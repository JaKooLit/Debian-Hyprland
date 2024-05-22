#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM with optional SDDM theme #

# installing with NO-recommends
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

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"


# Install SDDM (no-recommends)
printf "\n%s - Installing sddm.... \n" "${NOTE}"
for PKG1 in "${sddm1[@]}" ; do
  sudo apt-get install --no-install-recommends -y "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

# Installation of additional sddm stuff
printf "\n%s - Installing sddm additional stuff.... \n" "${NOTE}"
for PKG2 in "${sddm2[@]}"; do
  install_package "$PKG2" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG2 Package installation failed, Please check the installation logs"
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
    
# SDDM-themes
valid_input=false
while [ "$valid_input" != true ]; do
  read -n 1 -r -p "${CAT} OPTIONAL - Would you like to install SDDM themes? (y/n)" install_sddm_theme
  if [[ $install_sddm_theme =~ ^[Yy]$ ]]; then
    printf "\n%s - Installing Simple SDDM Theme\n" "${NOTE}"

    # Check if /usr/share/sddm/themes/simple-sddm exists and remove if it does
    if [ -d "/usr/share/sddm/themes/simple-sddm" ]; then
      sudo rm -rf "/usr/share/sddm/themes/simple-sddm"
      echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm' directory." 2>&1 | tee -a "$LOG"
    fi

    # Check if simple-sddm directory exists in the current directory and remove if it does
    if [ -d "simple-sddm" ]; then
      rm -rf "simple-sddm"
      echo -e "\e[1A\e[K${OK} - Removed existing 'simple-sddm' directory from the current location." 2>&1 | tee -a "$LOG"
    fi

    if git clone https://github.com/JaKooLit/simple-sddm.git; then
      while [ ! -d "simple-sddm" ]; do
        sleep 1
      done

      if [ ! -d "/usr/share/sddm/themes" ]; then
        sudo mkdir -p /usr/share/sddm/themes
        echo -e "\e[1A\e[K${OK} - Directory '/usr/share/sddm/themes' created." 2>&1 | tee -a "$LOG"
      fi

      sudo mv simple-sddm /usr/share/sddm/themes/
      echo -e "[Theme]\nCurrent=simple-sddm" | sudo tee "$sddm_conf_dir/theme.conf.user" &>> "$LOG"
     else
      echo -e "\e[1A\e[K${ERROR} - Failed to clone the theme repository. Please check your internet connection or repository availability." | tee -a "$LOG" >&2
    fi
    valid_input=true
  elif [[ $install_sddm_theme =~ ^[Nn]$ ]]; then
    printf "\n%s - No SDDM themes will be installed.\n" "${NOTE}" 2>&1 | tee -a "$LOG"
    valid_input=true
  else
    printf "\n%s - Invalid input. Please enter 'y' for Yes or 'n' for No.\n" "${ERROR}" 2>&1 | tee -a "$LOG"
    install_sddm_theme=""
  fi
done          		

clear