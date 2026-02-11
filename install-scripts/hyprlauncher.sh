#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprlauncher #

#specific branch or release (fallback)
tag_default="auto"
if [ -z "${HYPRLAUNCHER_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
TAG_SRC="${HYPRLAUNCHER_TAG:-$tag_default}"
[[ "$TAG_SRC" =~ ^(auto|latest)$ ]] && git_ref="" || git_ref="$TAG_SRC"

DO_INSTALL=1
[ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ] && { DO_INSTALL=0; echo "${NOTE} DRY RUN: install step will be skipped."; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprlauncher.log"
MLOG="install-$(date +%d-%H%M%S)_hyprlauncher2.log"

# Build-time dependencies specific to hyprlauncher
DEPS=(
  libqalculate-dev
)
printf "\n%s - Installing ${YELLOW}hyprlauncher dependencies${RESET} .... \n" "${INFO}"
for PKG in "${DEPS[@]}"; do
  re_install_package "$PKG" 2>&1 | tee -a "$LOG"
  if [ $? -ne 0 ]; then
    echo -e "\e[1A\e[K${ERROR} - ${YELLOW}$PKG${RESET} installation failed; see logs"
    exit 1
  fi
done

SRC_DIR="$SRC_ROOT/hyprlauncher"
rm -rf "$SRC_DIR" 2>/dev/null || true
printf "${INFO} Installing ${YELLOW}hyprlauncher ${git_ref:-default-branch}${RESET} ...\n"
if git clone --recursive ${git_ref:+-b "$git_ref"} https://github.com/hyprwm/hyprlauncher.git "$SRC_DIR"; then
    cd "$SRC_DIR" || exit 1
    BUILD_DIR="$BUILD_ROOT/hyprlauncher"
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
        if [ $DO_INSTALL -eq 1 ]; then
            BIN="$(basename "$(pwd)")"
            [ -f target/release/$BIN ] && sudo install -Dm755 target/release/$BIN "/usr/local/bin/$BIN"
        fi
    else
        echo "${ERROR} Unknown build system for hyprlauncher" | tee -a "$MLOG"
    fi
    mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprlauncher${RESET}" 2>&1 | tee -a "$LOG"
fi
printf "\n%.0s" {1..1}
