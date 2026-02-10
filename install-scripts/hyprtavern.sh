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

    # Ensure required protocol packages and scanner are installed when running this module standalone
    need_wl=0; need_hl=0; need_wlr=0; need_scanner=0
    # wayland-protocols check (look for a well-known file)
    if ! [ -f /usr/local/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml ] && ! [ -f /usr/share/wayland-protocols/stable/xdg-shell/xdg-shell.xml ]; then
        need_wl=1
    fi
    # hyprland-protocols check (repo installs to share/hyprland-protocols)
    if ! [ -d /usr/local/share/hyprland-protocols ] && ! [ -d /usr/share/hyprland-protocols ]; then
        need_hl=1
    fi
    # wlr-protocols check
    if ! [ -d /usr/share/wlr-protocols ] && ! [ -d /usr/local/share/wlr-protocols ]; then
        # optional on some distros but used by projects; install if missing
        need_wlr=1
    fi
    # hyprwayland-scanner binary
    if ! command -v hyprwayland-scanner >/dev/null 2>&1; then
        need_scanner=1
    fi

    if [ $need_wl -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/wayland-protocols-src.sh" ]; then
        echo "${NOTE} Installing missing wayland-protocols from source..."
        "$PARENT_DIR/install-scripts/wayland-protocols-src.sh"
    fi
    if [ $need_hl -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/hyprland-protocols.sh" ]; then
        echo "${NOTE} Installing missing hyprland-protocols from source..."
        "$PARENT_DIR/install-scripts/hyprland-protocols.sh"
    fi
    if [ $need_wlr -eq 1 ]; then
        # Prefer distro package if available
        if sudo apt-get update -y >/dev/null 2>&1 && apt-cache show wlr-protocols >/dev/null 2>&1; then
            echo "${NOTE} Installing missing wlr-protocols from apt..."
            sudo apt-get install -y wlr-protocols || true
        fi
    fi
    if [ $need_scanner -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/hyprwayland-scanner.sh" ]; then
        echo "${NOTE} Installing missing hyprwayland-scanner from source..."
        "$PARENT_DIR/install-scripts/hyprwayland-scanner.sh"
    fi

    # Ensure hyprwire library & protocols (required by hyprtavern)
    need_hw=0
    if ! pkg-config --exists hyprwire 2>/dev/null; then
        need_hw=1
    else
        # Even if hyprwire is present, make sure hyprwire-protocols are discoverable
        if ! pkg-config --exists hyprwire-protocols 2>/dev/null; then
            need_hw=1
        fi
    fi
    if [ $need_hw -eq 1 ] && [ -x "$PARENT_DIR/install-scripts/hyprwire.sh" ]; then
        echo "${NOTE} Installing/updating hyprwire (to provide hyprwire-protocols)..."
        "$PARENT_DIR/install-scripts/hyprwire.sh"
    fi

    # Discover protocol directories and export env vars consumed by generator tools
    WL_PROTO_DIR=""
    for d in /usr/local/share/wayland-protocols /usr/share/wayland-protocols; do [ -d "$d" ] && WL_PROTO_DIR="$d" && break; done
    HYP_PROTO_DIR=""
    for d in /usr/local/share/hyprland-protocols /usr/share/hyprland-protocols; do [ -d "$d" ] && HYP_PROTO_DIR="$d" && break; done
    WLR_PROTO_DIR=""
    for d in /usr/share/wlr-protocols /usr/local/share/wlr-protocols; do [ -d "$d" ] && WLR_PROTO_DIR="$d" && break; done
    HYPRWIRE_PROTO_DIR=""
    # Prefer pkg-config for hyprwire-protocols if available
    PC_WIRE_PROTO_DIR=$(pkg-config --variable=pkgdatadir hyprwire-protocols 2>/dev/null || true)
    if [ -n "$PC_WIRE_PROTO_DIR" ] && [ -d "$PC_WIRE_PROTO_DIR" ]; then
        HYPRWIRE_PROTO_DIR="$PC_WIRE_PROTO_DIR"
    else
        for d in /usr/local/share/hyprwire-protocols /usr/share/hyprwire-protocols; do [ -d "$d" ] && HYPRWIRE_PROTO_DIR="$d" && break; done
        # Fallback to the checked-out source if installed dir not found
        if [ -z "$HYPRWIRE_PROTO_DIR" ] && [ -d "$BUILD_ROOT/src/hyprwire/protocols" ]; then
            HYPRWIRE_PROTO_DIR="$BUILD_ROOT/src/hyprwire/protocols"
        fi
    fi

    # If pkg-config still cannot provide hyprwire-protocols, synthesize a local .pc pointing to the resolved dir
    if ! pkg-config --exists hyprwire-protocols 2>/dev/null && [ -n "$HYPRWIRE_PROTO_DIR" ]; then
        LOCAL_PC_DIR="$BUILD_ROOT/pkgconfig"
        mkdir -p "$LOCAL_PC_DIR"
        # Try to read hyprwire version via pkg-config; fall back to 0.0.0
        HW_VER=$(pkg-config --modversion hyprwire 2>/dev/null || echo "0.0.0")
        cat >"$LOCAL_PC_DIR/hyprwire-protocols.pc" <<EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
datadir=\${prefix}/share
# Override pkgdatadir to our resolved location
pkgdatadir=${HYPRWIRE_PROTO_DIR}

Name: hyprwire-protocols
Description: Protocol XMLs for hyprwire
Version: ${HW_VER}
EOF
        export PKG_CONFIG_PATH="$LOCAL_PC_DIR:/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
    fi

    # Export for hyprwayland-scanner/wayland-scanner invoked by the build
    [ -n "$WL_PROTO_DIR" ]       && export WAYLAND_PROTOCOLS_DIR="$WL_PROTO_DIR"
    [ -n "$HYP_PROTO_DIR" ]      && export HYPRLAND_PROTOCOLS_DIR="$HYP_PROTO_DIR"
    [ -n "$WLR_PROTO_DIR" ]      && export WLR_PROTOCOLS_DIR="$WLR_PROTO_DIR"
    [ -n "$HYPRWIRE_PROTO_DIR" ] && export HYPRWIRE_PROTOCOLS_DIR="$HYPRWIRE_PROTO_DIR"

    BUILD_DIR="$BUILD_ROOT/hyprtavern"
    mkdir -p "$BUILD_DIR"
    if [ -f CMakeLists.txt ]; then
        CMAKE_FLAGS=(
            -DCMAKE_BUILD_TYPE=Release
        )
        [ -n "$WL_PROTO_DIR" ]        && CMAKE_FLAGS+=( -DWAYLAND_PROTOCOLS_DIR="$WL_PROTO_DIR" )
        [ -n "$HYP_PROTO_DIR" ]       && CMAKE_FLAGS+=( -DHYPRLAND_PROTOCOLS_DIR="$HYP_PROTO_DIR" )
        [ -n "$WLR_PROTO_DIR" ]       && CMAKE_FLAGS+=( -DWLR_PROTOCOLS_DIR="$WLR_PROTO_DIR" )
        [ -n "$HYPRWIRE_PROTO_DIR" ]  && CMAKE_FLAGS+=( -DHYPRWIRE_PROTOCOLS_DIR="$HYPRWIRE_PROTO_DIR" )
        cmake -S . -B "$BUILD_DIR" "${CMAKE_FLAGS[@]}"
        cmake --build "$BUILD_DIR" -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
        if [ $DO_INSTALL -eq 1 ]; then sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f meson.build ]; then
        meson setup "$BUILD_DIR" --buildtype=release \
            ${WL_PROTO_DIR:+-Dwayland_protocols_dir="$WL_PROTO_DIR"} \
            ${HYP_PROTO_DIR:+-Dhyprland_protocols_dir="$HYP_PROTO_DIR"} \
            ${WLR_PROTO_DIR:+-Dwlr_protocols_dir="$WLR_PROTO_DIR"} \
            ${HYPRWIRE_PROTO_DIR:+-Dhyprwire_protocols_dir="$HYPRWIRE_PROTO_DIR"}
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
