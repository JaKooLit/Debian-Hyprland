#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Build and install wayland-protocols from source
# Provides a newer wayland-protocols.pc for pkg-config when distro version is too old

#specific tag or release (e.g., 1.45, 1.46)
tag="1.45"
# Auto-source centralized tags if env is unset
if [ -z "${WAYLAND_PROTOCOLS_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
# Allow environment override
if [ -n "${WAYLAND_PROTOCOLS_TAG:-}" ]; then tag="$WAYLAND_PROTOCOLS_TAG"; fi

# Dry-run support
DO_INSTALL=1
if [ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ]; then
    DO_INSTALL=0
    echo "${NOTE} DRY RUN: install step will be skipped."
fi

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_wayland-protocols.log"
MLOG="install-$(date +%d-%H%M%S)_wayland-protocols2.log"

printf "\n%s - Installing ${YELLOW}wayland-protocols (from source)${RESET} .... \n" "${INFO}"

# Clean previous clone (under build/src)
SRC_DIR="$SRC_ROOT/wayland-protocols"
if [ -d "$SRC_DIR" ]; then
    rm -rf "$SRC_DIR"
fi

# Clone and build (meson)
# Upstream: https://gitlab.freedesktop.org/wayland/wayland-protocols.git
printf "${INFO} Installing ${YELLOW}wayland-protocols $tag${RESET} ...\n"
repo_url="https://gitlab.freedesktop.org/wayland/wayland-protocols.git"
if git clone --depth=1 --filter=blob:none "$repo_url" "$SRC_DIR"; then
    cd "$SRC_DIR" || exit 1
    # Fetch tags and attempt to checkout the requested tag, trying both raw and v-prefixed
    git fetch --tags --depth=1 >/dev/null 2>&1 || true
    checked_out=0
    for candidate in "$tag" "v$tag"; do
        if git rev-parse -q --verify "refs/tags/$candidate" >/dev/null; then
            git checkout -q "refs/tags/$candidate"
            checked_out=1
            break
        fi
    done
    if [ "$checked_out" -ne 1 ]; then
        echo "${ERROR} Tag $tag not found in $repo_url" | tee -a "$LOG"
        echo "${NOTE} Available tags (truncated):" | tee -a "$LOG"
        git tag --list | tail -n 20 | tee -a "$LOG" || true
        exit 1
    fi
    # Install to /usr/local so pkg-config can prefer it over distro /usr
    BUILD_DIR="$BUILD_ROOT/wayland-protocols"
    mkdir -p "$BUILD_DIR"
    meson setup "$BUILD_DIR" --prefix=/usr/local
    meson compile -C "$BUILD_DIR" -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
    if [ $DO_INSTALL -eq 1 ]; then
        if sudo meson install -C "$BUILD_DIR" 2>&1 | tee -a "$MLOG" ; then
            printf "${OK} ${MAGENTA}wayland-protocols $tag${RESET} installed successfully.\n" 2>&1 | tee -a "$MLOG"
        else
            echo -e "${ERROR} Installation failed for ${YELLOW}wayland-protocols $tag${RESET}" 2>&1 | tee -a "$MLOG"
        fi
    else
        echo "${NOTE} DRY RUN: Skipping installation of wayland-protocols $tag."
    fi
    # Move additional logs to Install-Logs directory if they exist
    [ -f "$MLOG" ] && mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
    cd ..
else
    echo -e "${ERROR} Download failed for ${YELLOW}wayland-protocols $tag${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}