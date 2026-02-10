#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprtavern #

#specific branch or release (fallback)
tag_default="auto"
if [ -z "${HYPRTAVERN_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
TAG_SRC="${HYPRTAVERN_TAG:-$tag_default}"
[[ "$TAG_SRC" =~ ^(auto|latest)$ ]] && git_ref="" || git_ref="$TAG_SRC"

DO_INSTALL=1
[ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ] && { DO_INSTALL=0; echo "${NOTE} DRY RUN: install step will be skipped."; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprtavern.log"
MLOG="install-$(date +%d-%H%M%S)_hyprtavern2.log"

SRC_DIR="$SRC_ROOT/hyprtavern"
rm -rf "$SRC_DIR" 2>/dev/null || true
printf "${INFO} Installing ${YELLOW}hyprtavern ${git_ref:-default-branch}${RESET} ...\n"
if git clone --recursive ${git_ref:+-b "$git_ref"} https://github.com/hyprwm/hyprtavern.git "$SRC_DIR"; then
    cd "$SRC_DIR" || exit 1
    # Ensure submodules and tools are ready
    git submodule update --init --recursive || true

    # Make sure CMake/pkg-config find /usr/local installs (hyprland-protocols, hyprwayland-scanner, etc.)
    export PATH="/usr/local/bin:${PATH}"
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
    export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

    # Discover protocol directories and pass them explicitly to CMake if it supports them
    WL_PROTO_DIR=""
    for d in /usr/local/share/wayland-protocols /usr/share/wayland-protocols; do [ -d "$d" ] && WL_PROTO_DIR="$d" && break; done
    HYP_PROTO_DIR=""
    for d in /usr/local/share/hyprland-protocols /usr/share/hyprland-protocols; do [ -d "$d" ] && HYP_PROTO_DIR="$d" && break; done
    WLR_PROTO_DIR=""
    for d in /usr/share/wlr-protocols /usr/local/share/wlr-protocols; do [ -d "$d" ] && WLR_PROTO_DIR="$d" && break; done

    BUILD_DIR="$BUILD_ROOT/hyprtavern"
    mkdir -p "$BUILD_DIR"
    if [ -f CMakeLists.txt ]; then
        CMAKE_FLAGS=(
            -DCMAKE_BUILD_TYPE=Release
        )
        [ -n "$WL_PROTO_DIR" ]  && CMAKE_FLAGS+=( -DWAYLAND_PROTOCOLS_DIR="$WL_PROTO_DIR" )
        [ -n "$HYP_PROTO_DIR" ] && CMAKE_FLAGS+=( -DHYPRLAND_PROTOCOLS_DIR="$HYP_PROTO_DIR" )
        [ -n "$WLR_PROTO_DIR" ] && CMAKE_FLAGS+=( -DWLR_PROTOCOLS_DIR="$WLR_PROTO_DIR" )
        cmake -S . -B "$BUILD_DIR" "${CMAKE_FLAGS[@]}"
        cmake --build "$BUILD_DIR" -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
        if [ $DO_INSTALL -eq 1 ]; then sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f meson.build ]; then
        meson setup "$BUILD_DIR" --buildtype=release \
            ${WL_PROTO_DIR:+-Dwayland_protocols_dir="$WL_PROTO_DIR"} \
            ${HYP_PROTO_DIR:+-Dhyprland_protocols_dir="$HYP_PROTO_DIR"} \
            ${WLR_PROTO_DIR:+-Dwlr_protocols_dir="$WLR_PROTO_DIR"}
        meson compile -C "$BUILD_DIR"
        if [ $DO_INSTALL -eq 1 ]; then sudo meson install -C "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f Cargo.toml ]; then
        cargo build --release 2>&1 | tee -a "$MLOG"
        if [ $DO_INSTALL -eq 1 ]; then
            BIN="$(basename "$(pwd)")"
            [ -f target/release/$BIN ] && sudo install -Dm755 target/release/$BIN "/usr/local/bin/$BIN"
        fi
    else
        echo "${ERROR} Unknown build system for hyprtavern" | tee -a "$MLOG"
    fi
    mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprtavern${RESET}" 2>&1 | tee -a "$LOG"
fi
printf "\n%.0s" {1..1}
