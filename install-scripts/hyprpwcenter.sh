#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# hyprpwcenter #

#specific branch or release (fallback)
tag_default="auto"
if [ -z "${HYPRPWCENTER_TAG:-}" ]; then
  TAGS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/hypr-tags.env"
  [ -f "$TAGS_FILE" ] && source "$TAGS_FILE"
fi
TAG_SRC="${HYPRPWCENTER_TAG:-$tag_default}"
[[ "$TAG_SRC" =~ ^(auto|latest)$ ]] && git_ref="" || git_ref="$TAG_SRC"

DO_INSTALL=1
[ "$1" = "--dry-run" ] || [ "${DRY_RUN}" = "1" ] || [ "${DRY_RUN}" = "true" ] && { DO_INSTALL=0; echo "${NOTE} DRY RUN: install step will be skipped."; }

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

LOG="Install-Logs/install-$(date +%d-%H%M%S)_hyprpwcenter.log"
MLOG="install-$(date +%d-%H%M%S)_hyprpwcenter2.log"

SRC_DIR="$SRC_ROOT/hyprpwcenter"
rm -rf "$SRC_DIR" 2>/dev/null || true
printf "${INFO} Installing ${YELLOW}hyprpwcenter ${git_ref:-default-branch}${RESET} ...\n"
if git clone --recursive ${git_ref:+-b "$git_ref"} https://github.com/hyprwm/hyprpwcenter.git "$SRC_DIR"; then
    cd "$SRC_DIR" || exit 1
    BUILD_DIR="$BUILD_ROOT/hyprpwcenter"
    mkdir -p "$BUILD_DIR"

    # Debian trixie libstdc++ may lack std::vector::append_range (C++23). Detect and shim if needed.
    NEED_SHIM=0
    CXX_TEST="${CXX:-c++}"
    TMPD="$(mktemp -d)"
    cat >"$TMPD/append_range_test.cpp" <<'EOF'
#include <vector>
int main() {
  std::vector<int> v; v.append_range(std::vector<int>{1,2,3});
  return 0;
}
EOF
    if ! "$CXX_TEST" -std=c++23 -c "$TMPD/append_range_test.cpp" -o /dev/null >/dev/null 2>&1; then
      NEED_SHIM=1
    fi
    rm -rf "$TMPD"

    EXTRA_FLAGS=()
    if [ "$NEED_SHIM" -eq 1 ]; then
      echo "${NOTE} Applying append_range compatibility shim for hyprpwcenter (toolchain lacks std::vector::append_range)."
      APPEND_HDR="$(pwd)/append_range_compat.hpp"
      cat > "$APPEND_HDR" <<'EOF'
#pragma once
#include <iterator>
// Append any begin/end range to a container, supporting temporaries by binding to auto&&.
#define APPEND_RANGE(vec, ...) do { \
  auto&& _r = (__VA_ARGS__); \
  (vec).insert((vec).end(), std::begin(_r), std::end(_r)); \
} while(0)
EOF
      # Replace x.append_range(y) -> APPEND_RANGE(x, y) across sources
      PATCH_FILES=$(grep -RIl --exclude-dir=.git -E '\.\s*append_range\s*\(' src || true)
      if [ -n "$PATCH_FILES" ]; then
        echo "$PATCH_FILES" | xargs -r sed -ri 's/([A-Za-z_][A-Za-z0-9_:>.\-]*)\s*\.\s*append_range\s*\(/APPEND_RANGE(\1, /g'
      fi
      EXTRA_FLAGS+=( -DCMAKE_CXX_FLAGS="-include ${APPEND_HDR}" )
    fi

    if [ -f CMakeLists.txt ]; then
        cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=23 "${EXTRA_FLAGS[@]}"
        cmake --build "$BUILD_DIR" -j "$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
        if [ $DO_INSTALL -eq 1 ]; then sudo cmake --install "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f meson.build ]; then
        meson setup "$BUILD_DIR" --buildtype=release
        meson compile -C "$BUILD_DIR"
        if [ $DO_INSTALL -eq 1 ]; then sudo meson install -C "$BUILD_DIR" 2>&1 | tee -a "$MLOG"; else echo "${NOTE} DRY RUN: skip install" | tee -a "$MLOG"; fi
    elif [ -f Cargo.toml ]; then
        cargo build --release 2>&1 | tee -a "$MLOG"
        if [ $DO_INSTALL -eq 1 ]; then
            # Install common cargo-built binary name if present
            BIN="$(basename "$(pwd)")"
            [ -f target/release/$BIN ] && sudo install -Dm755 target/release/$BIN "/usr/local/bin/$BIN"
        fi
    else
        echo "${ERROR} Unknown build system for hyprpwcenter" | tee -a "$MLOG"
    fi
    mv "$MLOG" "$PARENT_DIR/Install-Logs/" || true
else
    echo -e "${ERROR} Download failed for ${YELLOW}hyprpwcenter${RESET}" 2>&1 | tee -a "$LOG"
fi
printf "\n%.0s" {1..1}