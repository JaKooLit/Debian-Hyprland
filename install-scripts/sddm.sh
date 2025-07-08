#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM with optional SDDM theme #

# installing with NO-recommends
sddm1=(
    sddm
)

sddm2=(
    qt6-5compat-dev
    qml6-module-qt5compat-graphicaleffects
    qt6-declarative-dev
    qt6-svg-dev
)

# login managers to attempt to disable
login=(
    lightdm
    gdm3
    gdm
    lxdm
    lxdm-gtk3
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"

# Install SDDM (no-recommends)
printf "\n%s - Installing ${SKY_BLUE}SDDM and dependencies${RESET} .... \n" "${NOTE}"
for PKG1 in "${sddm1[@]}"; do
    apt_install_no_recommends "$PKG1"
done

# Installation of additional sddm stuff
for PKG2 in "${sddm2[@]}"; do
    install_package "$PKG2" "$LOG"
done

# Check if other login managers are installed and disable their service before enabling SDDM
for login_manager in "${login[@]}"; do
    if dpkg -l | grep -q "^ii  $login_manager"; then
        echo "Disabling $login_manager..."
        if [[ $PEDANTIC_DRY -eq 1 ]]; then
            echo "${NOTE} Not disabling $login_manager.service with systemctl disable"
        else
            sudo systemctl disable "$login_manager.service" | tee -a "$LOG" 2>&1 || echo "Failed to disable $login_manager" >>"$LOG"
        fi
        echo "$login_manager disabled."
    fi
done

# Double check with systemctl
for manager in "${login[@]}"; do
    if systemctl is-active --quiet "$manager.service" >/dev/null 2>&1; then
        echo "$manager.service is active, disabling it..." >>"$LOG" 2>&1
        if [[ $DRY -eq 1 ]]; then
            echo "${NOTE} Not disabling \"$manager.service\" with systemctl disable --now" >>"$LOG" 2>&1
        else
            sudo systemctl disable "$manager.service" --now | tee -a "$LOG" 2>&1 || echo "Failed to disable $manager.service" >>"$LOG"
        fi
    else
        echo "$manager.service is not active" >>"$LOG" 2>&1
    fi
done

newlines 1
echo "${INFO} Activating sddm service........"
if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE} Not setting graphical.target to be default or enabling sddm.service"
else
    sudo systemctl set-default graphical.target 2>&1 | tee -a "$LOG"
    sudo systemctl enable sddm.service 2>&1 | tee -a "$LOG"
fi

wayland_sessions_dir=/usr/share/wayland-sessions
[ ! -d "$wayland_sessions_dir" ] && {
    echo "$CAT - $wayland_sessions_dir not found, creating..."
    if [[ $DRY -eq 1 ]]; then
        echo "${NOTE} Not making directory $wayland_sessions_dir with mkdir -p"
    else
        sudo mkdir -p "$wayland_sessions_dir" 2>&1 | tee -a "$LOG"
    fi
}

if [[ $DRY -eq 1 ]]; then
    echo "${NOTE} Not copying assets/hyprland.desktop to $wayland_sessions_dir/ with cp"
else
    sudo cp assets/hyprland.desktop "$wayland_sessions_dir/" 2>&1 | tee -a "$LOG"
fi

newlines 2
