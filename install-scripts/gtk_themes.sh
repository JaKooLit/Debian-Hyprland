#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# GTK Themes & ICONS and  Sourcing from a different Repo #

# Base utilities needed regardless of Debian branch
engine=(
    unzip
)

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_themes.log"

# Helper: check if apt has a candidate for a package
has_apt_candidate() {
  local pkg="$1"
  local cand
  cand=$(apt-cache policy "$pkg" 2>/dev/null | awk '/Candidate:/ {print $2}')
  [ -n "$cand" ] && [ "$cand" != "(none)" ]
}

# Build gtk2-engines-murrine from Debian source (preferred fallback)
build_murrine_from_debian_source() {
  echo "$NOTE Attempting to build gtk2-engines-murrine from Debian source..." | tee -a "$LOG"

  # Ensure basic build tooling
  sudo apt-get update >> "$LOG" 2>&1 || true
  sudo apt-get install -y --no-install-recommends git curl build-essential dpkg-dev devscripts equivs ca-certificates >> "$LOG" 2>&1 || return 1

  local workdir="$SRC_ROOT/murrine-debian-src"
  rm -rf "$workdir" && mkdir -p "$workdir"
  pushd "$workdir" >/dev/null || return 1

  # Prefer Debian packaging Git (works without deb-src enabled)
  if git clone --depth=1 https://salsa.debian.org/debian/gtk2-engines-murrine.git src >> "$LOG" 2>&1; then
    cd src || return 1
    # Install build-deps using the control file
    if ! sudo apt-get -y build-dep ./ >> "$LOG" 2>&1; then
      # Fallback to mk-build-deps if the above is not supported
      sudo mk-build-deps -i -t "apt-get -y" -r debian/control >> "$LOG" 2>&1 || return 1
    fi

    # Build binary package only
    if dpkg-buildpackage -us -uc -b >> "$LOG" 2>&1; then
      cd ..
      if sudo apt-get install -y ./gtk2-engines-murrine_*_*.deb >> "$LOG" 2>&1; then
        echo "$OK Installed gtk2-engines-murrine from locally built Debian source" | tee -a "$LOG"
        popd >/dev/null
        return 0
      fi
    fi
  fi

  # If Git route failed, try downloading released Debian source tarballs directly
  rm -rf "$workdir" && mkdir -p "$workdir" && cd "$workdir" || return 1
  local versions=("0.98.2-4" "0.98.2-3")
  local base_url="https://deb.debian.org/debian/pool/main/g/gtk2-engines-murrine"
  for ver in "${versions[@]}"; do
    local origver
    origver="${ver%%-*}"
    echo "$INFO Trying Debian source version $ver ..." | tee -a "$LOG"
    if curl -fsSLO "$base_url/gtk2-engines-murrine_${ver}.dsc" \
       && curl -fsSLO "$base_url/gtk2-engines-murrine_${origver}.orig.tar.xz" \
       && curl -fsSLO "$base_url/gtk2-engines-murrine_${ver}.debian.tar.xz"; then
      dpkg-source -x "gtk2-engines-murrine_${ver}.dsc" >> "$LOG" 2>&1 || continue
      cd "gtk2-engines-murrine-${origver}" || continue
      if ! sudo apt-get -y build-dep ./ >> "$LOG" 2>&1; then
        sudo mk-build-deps -i -t "apt-get -y" -r debian/control >> "$LOG" 2>&1 || { cd ..; continue; }
      fi
      if dpkg-buildpackage -us -uc -b >> "$LOG" 2>&1; then
        cd ..
        if sudo apt-get install -y ./gtk2-engines-murrine_*_*.deb >> "$LOG" 2>&1; then
          echo "$OK Installed gtk2-engines-murrine from Debian source version $ver" | tee -a "$LOG"
          popd >/dev/null
          return 0
        fi
      fi
      cd "$workdir" || true
    fi
  done

  popd >/dev/null || true
  echo "$ERROR Building gtk2-engines-murrine from Debian source failed." | tee -a "$LOG"
  return 1
}

# Last-resort: temporarily pull binary from Debian unstable (sid) with pinning
install_murrine_from_sid() {
  echo "$WARN Falling back to installing gtk2-engines-murrine from Debian unstable (sid)..." | tee -a "$LOG"
  local sid_list="/etc/apt/sources.list.d/temp-sid.list"
  local sid_pin="/etc/apt/preferences.d/temp-sid-pin"

  echo "deb http://deb.debian.org/debian sid main" | sudo tee "$sid_list" >/dev/null
  sudo tee "$sid_pin" >/dev/null <<EOF
Package: *
Pin: release a=unstable
Pin-Priority: 100
EOF
  sudo apt-get update >> "$LOG" 2>&1 || { echo "$ERROR apt update failed for sid." | tee -a "$LOG"; return 1; }
  if sudo apt-get install -y -t sid gtk2-engines-murrine >> "$LOG" 2>&1; then
    echo "$OK Installed gtk2-engines-murrine from sid." | tee -a "$LOG"
    # Clean up temp apt entries
    sudo rm -f "$sid_list" "$sid_pin"
    sudo apt-get update >> "$LOG" 2>&1 || true
    return 0
  else
    echo "$ERROR Failed to install gtk2-engines-murrine from sid." | tee -a "$LOG"
    sudo rm -f "$sid_list" "$sid_pin"
    sudo apt-get update >> "$LOG" 2>&1 || true
    return 1
  fi
}

install_murrine_engine() {
  local pkg="gtk2-engines-murrine"

  if dpkg -l | grep -q -w "$pkg"; then
    echo -e "${INFO} ${MAGENTA}$pkg${RESET} is already installed. Skipping..." | tee -a "$LOG"
    return 0
  fi

  if has_apt_candidate "$pkg"; then
    install_package "$pkg" "$LOG"
    if dpkg -l | grep -q -w "$pkg"; then return 0; fi
  fi

  # Try building from source
  if build_murrine_from_debian_source; then
    return 0
  fi

  # Last resort: sid
  install_murrine_from_sid
}

# 1) Install base utilities
for PKG1 in "${engine[@]}"; do
  install_package "$PKG1" "$LOG"
done

# 2) Ensure murrine (GTK2 engine) is present, with robust fallbacks
install_murrine_engine

# 3) Clone and deploy themes
# Check if the directory exists and delete it if present (under build/src)
SRC_DIR="$SRC_ROOT/GTK-themes-icons"
if [ -d "$SRC_DIR" ]; then
    echo "$NOTE GTK themes and Icons directory exist..deleting..." 2>&1 | tee -a "$LOG"
    rm -rf "$SRC_DIR" 2>&1 | tee -a "$LOG"
fi

echo "$NOTE Cloning ${SKY_BLUE}GTK themes and Icons${RESET} repository..." 2>&1 | tee -a "$LOG"
if git clone --depth=1 https://github.com/JaKooLit/GTK-themes-icons.git "$SRC_DIR"; then
    cd "$SRC_DIR"
    chmod +x auto-extract.sh
    ./auto-extract.sh
    cd "$PARENT_DIR"
    echo "$OK Extracted GTK Themes & Icons to ~/.icons & ~/.themes directories" 2>&1 | tee -a "$LOG"
else
    echo "$ERROR Download failed for GTK themes and Icons.." 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..2}
