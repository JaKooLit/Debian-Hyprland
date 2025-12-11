#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Main Hyprland Package#

#specific branch or release
tag="v0.52.2"
# Allow environment override
if [ -n "${HYPRLAND_TAG:-}" ]; then tag="$HYPRLAND_TAG"; fi

# Dry-run support
DO_INSTALL=1
if [ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

hyprland=(
  clang
  llvm
  libxcb-errors-dev
  libre2-dev
  libglaze-dev
  libudis86-dev
  libinotify-ocaml-dev
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprland.log"
MLOG="install-$(date +%d-%H%M%S)_hyprland2.log"

# Installation of dependencies
printf "\n%s - Installing hyprland additional dependencies.... \n" "${NOTE}"

for PKG1 in "${hyprland[@]}"; do
  install_package "$PKG1" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - $PKG1 Package installation failed, Please check the installation logs"
    exit 1
  fi
done

printf "\n%.0s" {1..1}

# Installation of dependencies (glaze)
printf "\n%s - Installing Hyprland additional dependencies (glaze).... \n" "${NOTE}"

# Check if /usr/include/glaze exists
if [ ! -d /usr/include/glaze ]; then
    echo "${INFO} ${YELLOW}Glaze${RESET} is not installed. Installing ${YELLOW}glaze from assets${RESET} ..."
    sudo dpkg -i assets/libglaze-dev_4.4.3-1_all.deb 2>&1 | tee -a "$LOG"
    sudo apt-get install -f -y 2>&1 | tee -a "$LOG"
    echo "${INFO} ${YELLOW}libglaze-dev from assets${RESET} installed."
fi


printf "\n%.0s" {1..1}

# Clone, build, and install Hyprland using Cmake
printf "${NOTE} Cloning and Installing ${YELLOW}Hyprland $tag${RESET} ...\n"

# Check if Hyprland folder exists and remove it
if [ -d "Hyprland" ]; then
  printf "${NOTE} Removing existing Hyprland folder...\n"
  rm -rf "Hyprland" 2>&1 | tee -a "$LOG"
fi

if git clone --recursive -b $tag "https://github.com/hyprwm/Hyprland"; then
  cd "Hyprland" || exit 1
  # Apply patch only if it applies cleanly; otherwise skip
  if [ -f ../assets/0001-fix-hyprland-compile-issue.patch ]; then
    if patch -p1 --dry-run < ../assets/0001-fix-hyprland-compile-issue.patch >/dev/null 2>&1; then
      patch -p1 < ../assets/0001-fix-hyprland-compile-issue.patch
    else
      echo "${NOTE} Hyprland compile patch does not apply on $tag; skipping."
    fi
  fi
  # By default, build Hyprland with bundled hyprutils/hyprlang to avoid version mismatches
  # You can force system libs by exporting USE_SYSTEM_HYPRLIBS=1 before running this script.
USE_SYSTEM=${USE_SYSTEM_HYPRLIBS:-1}
  if [ "$USE_SYSTEM" = "1" ]; then
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
    export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"
    SYSTEM_FLAGS=("-DUSE_SYSTEM_HYPRUTILS=ON" "-DUSE_SYSTEM_HYPRLANG=ON")
  else
    # Ensure we do not accidentally pick up mismatched system headers
    unset PKG_CONFIG_PATH || true
    SYSTEM_FLAGS=("-DUSE_SYSTEM_HYPRUTILS=OFF" "-DUSE_SYSTEM_HYPRLANG=OFF")
  fi

  # Make sure submodules are present when building bundled deps
  git submodule update --init --recursive || true

  # Force Clang toolchain to support required language features and flags
  export CC="${CC:-clang}"
  export CXX="${CXX:-clang++}"
  CONFIG_FLAGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_C_COMPILER="${CC}"
    -DCMAKE_CXX_COMPILER="${CXX}"
    -DCMAKE_CXX_STANDARD=26
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DCMAKE_CXX_EXTENSIONS=ON
    "${SYSTEM_FLAGS[@]}"
  )
  cmake -S . -B build "${CONFIG_FLAGS[@]}"
  cmake --build build -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"

  if [ $DO_INSTALL -eq 1 ]; then
    if sudo cmake --install build 2>&1 | tee -a "$MLOG"; then
      printf "${OK} ${MAGENTA}Hyprland tag${RESET}  installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
      echo -e "${ERROR} Installation failed for ${YELLOW}Hyprland $tag${RESET}" 2>&1 | tee -a "$MLOG"
    fi
  else
    echo "${NOTE} DRY RUN: Skipping installation of Hyprland $tag."
  fi
  [ -f "$MLOG" ] && mv "$MLOG" ../Install-Logs/
  cd ..
else
  echo -e "${ERROR} Download failed for ${YELLOW}Hyprland $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
