#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprpicker #

#specific branch or release (fallback)
tag_default="auto"
# Override from centralized tags if available
if [ -z "${HYPRPICKER_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
TAG_SRC="${HYPRPICKER_TAG:-$tag_default}"
if [[ "$TAG_SRC" =~ ^(auto|latest)$ ]]; then git_ref=""; else git_ref="$TAG_SRC"; fi

# Dry-run support
DO_INSTALL=1
[ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ] && { DO_INSTALL=0; echo "${NOTE} DRY RUN: install step will be skipped."; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprpicker.log"
MLOG="install-$(date +%d-%H%M%S)_hyprpicker2.log"

# Ensure base build deps are present; most are handled by 00-dependencies.sh
# Additional common deps for hyprpicker (Wayland, xdg-desktop etc.) are already installed elsewhere.

SRC_DIR="$SRC_ROOT/hyprpicker"
rm -rf "$SRC_DIR" 2>/dev/null || true
printf "${INFO} Installing ${YELLOW}hyprpicker ${git_ref:-default-branch}${RESET} ...\n"
if git clone --recursive ${git_ref:+-b "$git_ref"} https://github.com/hyprwm/hyprpicker.git "$SRC_DIR"; then
    cd "$SRC_DIR" || exit 1
    BUILD_DIR="$BUILD_ROOT/hyprpicker"
    mkdir -p "$BUILD_DIR"
    if [ -f CMakeLists.txt ]; then
        cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
        cmake --build "$BUILD_DIR" -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
        if [ $DO_INSTALL -eq 1 ]; then sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f meson.build ]; then
        meson setup "$BUILD_DIR" --buildtype=release
        meson compile -C "$BUILD_DIR"
        if [ $DO_INSTALL -eq 1 ]; then sudo meson install -C "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f Cargo.toml ]; then
        cargo build --release 2>&1 | tee -a "$MLOG"
        if [ $DO_INSTALL -eq 1 ]; then sudo install -Dm755 target/release/hyprpicker /usr/local/bin/hyprpicker; fi
    else
        echo "${ERROR} Unknown build system for hyprpicker" | tee -a "$MLOG"
    fi
    mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprpicker${RESET}" 2>&1 | tee -a "$LOG"
fi
printf "\n%.0s" {1..1}