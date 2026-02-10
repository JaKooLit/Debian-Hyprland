#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprwire-protocols (XML bundle consumed by hyprwire-scanner users like hyprtavern)

#specific branch or release (fallback)
tag_default="auto"
if [ -z "${HYPRWIRE_PROTOCOLS_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
TAG_SRC="${HYPRWIRE_PROTOCOLS_TAG:-$tag_default}"
[[ "$TAG_SRC" =~ ^(auto|latest)$ ]] && git_ref="" || git_ref="$TAG_SRC"

DO_INSTALL=1
[ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ] && { DO_INSTALL=0; echo "${NOTE} DRY RUN: install step will be skipped."; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprwire-protocols.log"
MLOG="install-$(date +%d-%H%M%S)_hyprwire-protocols2.log"

DEST_DIR="/usr/local/share/hyprwire-protocols"

SRC_DIR="$SRC_ROOT/hyprwire-protocols"
rm -rf "$SRC_DIR" 2>/dev/null || true
printf "${INFO} Installing ${YELLOW}hyprwire-protocols ${git_ref:-default-branch}${RESET} ...\n"
if git clone --recursive ${git_ref:+-b "$git_ref"} https://github.com/hyprwm/hyprwire-protocols.git "$SRC_DIR"; then
    # Protocol XMLs are expected under $SRC_DIR/hyprtavern/*.xml etc.
    if [ $DO_INSTALL -eq 1 ]; then
        sudo install -d "$DEST_DIR"
        sudo cp -a "$SRC_DIR"/* "$DEST_DIR/"
        echo "${OK} Installed protocols to $DEST_DIR" | tee -a "$MLOG"
        # Synthesize a pkg-config file so CMake can discover pkgdatadir
        PC_DIR="/usr/local/lib/pkgconfig"
        [ -d "$PC_DIR" ] || PC_DIR="/usr/local/share/pkgconfig"
        sudo install -d "$PC_DIR"
        VER="$(git -C "$SRC_DIR" describe --tags --abbrev=0 2>/dev/null || echo 0.0.0)"
        TMP_PC="$(mktemp)" && cat > "$TMP_PC" <<EOF
prefix=/usr/local
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
datadir=\${prefix}/share
pkgdatadir=${DEST_DIR}/protocols

Name: hyprwire-protocols
Description: Protocol XMLs for hyprwire-based generators
Version: ${VER}
EOF
        sudo install -m644 "$TMP_PC" "$PC_DIR/hyprwire-protocols.pc"
        rm -f "$TMP_PC"
      else
        echo "${NOTE} DRY RUN: would install protocols to $DEST_DIR and create hyprwire-protocols.pc" | tee -a "$MLOG"
      fi
    mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprwire-protocols${RESET}" 2>&1 | tee -a "$LOG"
fi
printf "\n%.0s" {1..1}
