#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots Packages #
# edit your packages desired here. 
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in Debian Official Repo

# add packages wanted here
Extra=(

)

# packages neeeded
hypr_package=( 
  cliphist
  grim
  gvfs
  gvfs-backends
  inxi
  imagemagick
  kitty
  nano
  nwg-look
  pavucontrol
  playerctl
  polkit-kde-agent-1
  python3-requests
  python3-pip
  qt5ct
  qt5-style-kvantum
  qt5-style-kvantum-themes
  qt6ct
  slurp
  sway-notification-center
  swappy
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
  eog
  fastfetch
  gnome-system-monitor
  mousepad
  mpv
  mpv-mpris
  nvtop
  pamixer
  qalculate-gtk
  vim
)

# List of packages to uninstall as it conflicts with swaync or causing swaync to not function properly
uninstall=(
  dunst
  mako
  rofi
  cargo
)

# List packages to force reinstall
force=(
  yad
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"

# Installation of main components
printf "\n%s - Installing ${SKY_BLUE}KooL's hyprland necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
  install_package "$PKG1" "$LOG"
done

printf "\n%s - ${SKY_BLUE}Uninstalling some packages${RESET} inorder for dots to work properly \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
  uninstall_package "$PKG" "$LOG"
done

for PKG2 in "${force[@]}"; do
  re_install_package "$PKG2" "$LOG"
done


# install YAD from assets. NOTE This is downloaded from SID repo and sometimes
# Trixie is removing YAD for some strange reasons
# Check if yad is installed
if ! command -v yad &> /dev/null; then
  echo "${INFO} Installing ${YELLOW}YAD from assets${RESET} ..."
  sudo dpkg -i assets/yad_0.40.0-1+b2_amd64.deb
  sudo apt-get install -f -y
  echo "${INFO} ${YELLOW}YAD from assets${RESET} succesfully installed ..."
fi

printf "\n%.0s" {1..2}

# Install up-to-date Rust
echo "${INFO} Installing most ${YELLOW}up to date Rust compiler${RESET} ..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tee -a "$LOG"
source "$HOME/.cargo/env"

## making brightnessctl work
sudo chmod +s $(which brightnessctl) 2>&1 | tee -a "$LOG" || true

printf "\n%.0s" {1..2}
