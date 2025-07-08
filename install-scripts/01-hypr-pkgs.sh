#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots Packages #
# edit your packages desired here.
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in Debian Official Repo

# add packages wanted here
Extra=(

)

# packages needed
hypr_package=(
    cliphist
    grim
    gvfs
    gvfs-backends
    inxi
    imagemagick
    kitty
    nano
    pavucontrol
    playerctl
    polkit-kde-agent-1
    python3-requests
    python3-pip
    qt5ct
    qt-style-kvantum
    qt-style-kvantum-themes
    qt6ct
    slurp
    swappy
    sway-notification-center
    unzip
    waybar
    wget
    wl-clipboard
    wlogout
    xdg-user-dirs
    xdg-utils
    yad
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
    brightnessctl
    btop
    cava
    fastfetch
    loupe
    gnome-system-monitor
    mousepad
    mpv
    mpv-mpris
    nwg-look
    nwg-displays
    nvtop
    pamixer
    qalculate-gtk
)

# packages to force reinstall
force=(
    imagemagick
    wayland-protocols
)

# List of packages to uninstall as it conflicts with swaync or causing swaync to not function properly
uninstall=(
    dunst
    mako
    rofi
    cargo
    # These conflict with source repositories
    hyprcursor-util
    hyprland
    hyprland-dev
    hyprland-protocols
    hyprpaper
    hyprwayland-scanner
    libhyprcursor-dev
    libhyprcursor0
    libhyprlang-dev
    libhyprlang2
    libhyprutils-dev
    libhyprutils0
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

PARENT_DIR=$SCRIPT_DIR/..

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
LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

# conflicting packages removal
overall_failed=0
printf "\n%s - ${SKY_BLUE}Removing some packages${RESET} as it conflicts with KooL's Hyprland Dots \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
    ! uninstall_package "$PKG" 2>&1 | tee -a "$LOG" && overall_failed=1
done

if [ $overall_failed -ne 0 ]; then
    echo "${ERROR} Some packages failed to uninstall. Please check the log."
fi

newlines 1

# Installation of main components
printf "\n%s - Installing ${SKY_BLUE}KooL's hyprland necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
    install_package "$PKG1" "$LOG"
done

newlines 1

for PKG2 in "${force[@]}"; do
    re_install_package "$PKG2" "$LOG"
done

newlines 1
# install YAD from assets. NOTE This is downloaded from EXPERIMENTAL repo and sometimes
# Trixie is removing YAD for some strange reasons
# Check if yad is installed
if ! command -v yad &>/dev/null; then
    echo "${INFO} Installing ${YELLOW}YAD from assets${RESET} ..."
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} Not installing yad=7.2-1_amd64 from $PARENT_DIR/assets/yad_7.2-1_amd64.deb"
    else
        verbose_log "Installing $PARENT_DIR/assets/yad_.2-1_amd64.deb with dpkg -i"
        sudo dpkg -i assets/yad_7.2-1_amd64.deb
        verbose_log "Attempting to fix broken packages just in case."
        sudo apt install --fix-broken --assume-yes
        echo "${INFO} ${YELLOW}YAD from assets${RESET} succesfully installed ..."
    fi
fi

newlines 2

if [[ $DRY -eq 1 ]]; then
    echo "${NOTE} I am not installing the Rust compiler."
else
    # Install up-to-date Rust
    echo "${INFO} Installing most ${YELLOW}up to date Rust compiler${RESET} ..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tee -a "$LOG"
fi
# shellcheck disable=SC1091
source "$HOME/.cargo/env"

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE} Not setting setuid bit of $(which brightnessctl) executable."
else
    ## making brightnessctl work
    sudo chmod +s "$(which brightnessctl)" 2>&1 | tee -a "$LOG" || true
fi

newlines 2
