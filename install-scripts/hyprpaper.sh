#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprpaper (build from source)

#specific branch or release (fallback)
tag_default="auto"
if [ -z "${HYPRPAPER_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
TAG_SRC="${HYPRPAPER_TAG:-$tag_default}"
[[ "$TAG_SRC" =~ ^(auto|latest)$ ]] && git_ref="" || git_ref="$TAG_SRC"

DO_INSTALL=1
[ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ] && { DO_INSTALL=0; echo "${NOTE} DRY RUN: install step will be skipped."; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprpaper.log"
MLOG="install-$(date +%d-%H%M%S)_hyprpaper2.log"

# Ensure toolchain & common deps for hypr* projects
COMMON_DEPS=(
  cmake
  ninja-build
  pkg-config
  build-essential
  libwayland-dev
  libxkbcommon-dev
)
printf "\n%s - Ensuring ${YELLOW}common build dependencies${RESET} .... \n" "${INFO}"
for PKG in "${COMMON_DEPS[@]}"; do
  install_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - ${YELLOW}$PKG${RESET} installation failed; see logs"
    exit 1
  fi
done

# Prefer locally built hypr* libs and scanner when available
export PATH="/usr/local/bin:${PATH}"
if [[ ":${PKG_CONFIG_PATH:-}:" != *":/usr/local/share/pkgconfig:"* ]]; then
  export PKG_CONFIG_PATH="/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
fi
if [[ ":${PKG_CONFIG_PATH}:" != *":/usr/local/lib/pkgconfig:"* ]]; then
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
fi
export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

# Ensure hyprwayland-scanner is present
if ! command -v hyprwayland-scanner >/dev/null 2>&1; then
  if [ -x "$PARENT_DIR/install-scripts/hyprwayland-scanner.sh" ]; then
    echo "${NOTE} Installing missing hyprwayland-scanner from source..."
    "$PARENT_DIR/install-scripts/hyprwayland-scanner.sh"
  else
    echo "${WARN} hyprwayland-scanner not found and helper script missing; attempting to proceed."
  fi
fi

# Ensure required hypr* libs are installed (hyprlang, hyprutils, hyprgraphics)
need_lang=0; need_utils=0; need_graphics=0
pkg-config --exists hyprlang || need_lang=1
pkg-config --exists hyprutils || need_utils=1
pkg-config --exists hyprgraphics || need_graphics=1

if [ $need_lang -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/hyprlang.sh" ]; then
  echo "${NOTE} Installing missing hyprlang..."; "$PARENT_DIR/install-scripts/hyprlang.sh"
fi
if [ $need_utils -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/hyprutils.sh" ]; then
  echo "${NOTE} Installing missing hyprutils..."; "$PARENT_DIR/install-scripts/hyprutils.sh"
fi
if [ $need_graphics -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/hyprgraphics.sh" ]; then
  echo "${NOTE} Installing missing hyprgraphics..."; "$PARENT_DIR/install-scripts/hyprgraphics.sh"
fi

# Optional but recommended protocols availability
WL_PROTO_DIR=""
for d in /usr/local/share/wayland-protocols /usr/share/wayland-protocols; do [ -d "$d" ] && WL_PROTO_DIR="$d" && break; done
HYP_PROTO_DIR=""
for d in /usr/local/share/hyprland-protocols /usr/share/hyprland-protocols; do [ -d "$d" ] && HYP_PROTO_DIR="$d" && break; done
[ -n "$WL_PROTO_DIR" ]  && export WAYLAND_PROTOCOLS_DIR="$WL_PROTO_DIR"
[ -n "$HYP_PROTO_DIR" ] && export HYPRLAND_PROTOCOLS_DIR="$HYP_PROTO_DIR"

SRC_DIR="$SRC_ROOT/hyprpaper"
rm -rf "$SRC_DIR" 2>/dev/null || true
printf "${INFO} Installing ${YELLOW}hyprpaper ${git_ref:-default-branch}${RESET} ...\n"
if git clone --recursive ${git_ref:+-b "$git_ref"} https://github.com/hyprwm/hyprpaper.git "$SRC_DIR"; then
  cd "$SRC_DIR" || exit 1
  BUILD_DIR="$BUILD_ROOT/hyprpaper"
  mkdir -p "$BUILD_DIR"

  # Build with CMake
  CMAKE_FLAGS=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_PREFIX=/usr/local
    -DCMAKE_CXX_STANDARD=23
  )
  [ -n "$WL_PROTO_DIR" ]  && CMAKE_FLAGS+=( -DWAYLAND_PROTOCOLS_DIR="$WL_PROTO_DIR" )
  [ -n "$HYP_PROTO_DIR" ] && CMAKE_FLAGS+=( -DHYPRLAND_PROTOCOLS_DIR="$HYP_PROTO_DIR" )

  cmake -S . -B "$BUILD_DIR" "${CMAKE_FLAGS[@]}"
  cmake --build "$BUILD_DIR" -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
  if [ $DO_INSTALL -eq 1 ]; then
    if sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG" ; then
      printf "${OK} hyprpaper installed successfully.\n" 2>&1 | tee -a "$MLOG"
    else
      echo -e "${ERROR} Installation failed for hyprpaper." 2>&1 | tee -a "$MLOG"
    fi
  else
    echo "${NOTE} DRY RUN: Skipping installation of hyprpaper ${git_ref:-default-branch}." | tee -a "$MLOG"
  fi
  [ -f "$MLOG" ] && mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
else
  echo -e "${ERROR} Download failed for ${YELLOW}hyprpaper${RESET}" 2>&1 | tee -a "$LOG"
fi
printf "\n%.0s" {1..1}
