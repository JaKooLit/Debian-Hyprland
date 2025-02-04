#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Rofi-Wayland) #

rofi=(
  bison
  flex
  pandoc
  doxygen
  cppcheck
  libmpdclient-dev
  libnl-3-dev
  libasound2-dev
  libstartup-notification0-dev
  libwayland-client0
  libxcb-ewmh-dev
  libxcb-cursor-dev
  libxcb-icccm4-dev
  libxcb-randr0-dev
  libxcb-render-util0-dev
  libxcb-util-dev
  libxcb-xkb-dev
  libxcb-xinerama0-dev
  libxkbcommon-dev
  libxkbcommon-x11-dev
  imagemagick
  wget
)

rofi_tag="1.7.8+wayland1"
## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_rofi_wayland.log"
MLOG="install-$(date +%d-%H%M%S)_rofi_wayland2.log"

# uninstall other rofi
for PKG in "rofi" "bison"; do
  uninstall_package "$PKG" "$LOG"
done

sleep 1
printf "\n%.0s" {1..2}
# Installation of main components
printf "\n%s - Installing ${SKY_BLUE}rofi-wayland dependencies${RESET}.... \n" "${INFO}"

 for FORCE in "${rofi[@]}"; do
   re_install_package "$FORCE" 2>&1 | tee -a "$LOG"
  done

printf "\n%.0s" {1..2}
# Clone and build rofi - wayland
printf "${NOTE} Installing ${SKY_BLUE}rofi-wayland${RESET}...\n"

# Check if rofi folder exists
if [ -d "$rofi_tag" ]; then
  rm -rf "$rofi_tag"
fi

# cloning rofi-wayland
printf "${NOTE} Downloading ${YELLOW}rofi-wayland $rofi_tag${RESET} from releases...\n"
wget https://github.com/lbonn/rofi/releases/download/1.7.8%2Bwayland1/rofi-1.7.8+wayland1.tar.gz

if [ -f "$rofi_tag.tar.gz" ]; then
  printf "${OK} ${YELLOW}rofi-wayland $rofi_tag${RESET} downloaded successfully.\n" 2>&1 | tee -a "$LOG"
  tar xf $rofi_tag.tar.gz
fi

cd $rofi_tag || exit 1

# Proceed with the installation steps
if meson setup build && ninja -C build ; then
  if sudo ninja -C build install 2>&1 | tee -a "$MLOG"; then
    printf "${OK} rofi-wayland installed successfully.\n" 2>&1 | tee -a "$MLOG"
  else
    echo -e "${ERROR} Installation failed for ${YELLOW}rofi-wayland $rofi_tag${RESET}" 2>&1 | tee -a "$MLOG"
  fi
else
  echo -e "${ERROR} Meson setup or ninja build failed for ${YELLOW}rofi-wayland $rofi_tag${RESET}" 2>&1 | tee -a "$MLOG"
fi

# Move logs to Install-Logs directory
mv "$MLOG" ../Install-Logs/ || true
cd .. || exit 1

# clean up
rm -rf $rofi_tag.tar.gz

clear
