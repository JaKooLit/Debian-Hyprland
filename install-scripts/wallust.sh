#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# wallust - pywal colors replacement #

wallust=(
  wallust
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_wallust.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG")"

# Minimum version required
MIN_VER="3.5.1"

# Compare versions using dpkg if available, else sort -V
version_ge() {
  local a="$1" b="$2"
  if command -v dpkg >/dev/null 2>&1; then
    dpkg --compare-versions "$a" ge "$b"
    return $?
  fi
  # Fallback: returns 0 if a >= b
  [ "$(printf '%s\n%s\n' "$b" "$a" | sort -V | tail -n1)" = "$a" ]
}

# Detect existing wallust and skip if version is sufficient
if command -v wallust >/dev/null 2>&1; then
  EXISTING_VER=$(wallust --version 2>/dev/null | grep -oE '[0-9]+(\.[0-9]+){1,3}' | head -1 || true)
  if [ -n "$EXISTING_VER" ] && version_ge "$EXISTING_VER" "$MIN_VER"; then
    echo "${OK} wallust ${YELLOW}$EXISTING_VER${RESET} detected (>= ${MIN_VER}); skipping build." | tee -a "$LOG"
    exit 0
  else
    echo "${INFO} wallust ${EXISTING_VER:-unknown} found; upgrading to >= ${MIN_VER}." | tee -a "$LOG"
  fi
fi

# Install up-to-date Rust (only if not present)
if ! command -v cargo >/dev/null 2>&1; then
  echo "${INFO} Installing ${YELLOW}Rust toolchain${RESET} ..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tee -a "$LOG"
  source "$HOME/.cargo/env"
else
  # Ensure cargo bin path is available
  source "$HOME/.cargo/env" 2>/dev/null || true
fi

printf "\n%.0s" {1..2}

# Remove any old Wallust binary only if we are rebuilding
if [[ -f "/usr/local/bin/wallust" ]]; then
    echo "Removing existing Wallust binary..." 2>&1 | tee -a "$LOG"
    sudo rm -f "/usr/local/bin/wallust"
fi

printf "\n%.0s" {1..2}

# Install Wallust using Cargo
for WALL in "${wallust[@]}"; do
    cargo_install "$WALL" "$LOG"
    if [ $? -eq 0 ]; then  
        echo "${OK} ${MAGENTA}Wallust${RESET} installed successfully." | tee -a "$LOG"
    else
        echo "${ERROR} Installation of ${MAGENTA}$WALL${RESET} failed. Check the log file $LOG for details." | tee -a "$LOG"
        exit 1
    fi
done
printf "\n%.0s" {1..1}
# Move the newly compiled binary to /usr/local/bin
echo "Moving Wallust binary to /usr/local/bin..." | tee -a "$LOG"
if sudo mv "$HOME/.cargo/bin/wallust" /usr/local/bin 2>&1 | tee -a "$LOG"; then
    echo "${OK} Wallust binary moved successfully to /usr/local/bin." | tee -a "$LOG"
else
    echo "${ERROR} Failed to move Wallust binary. Check the log file $LOG for details." | tee -a "$LOG"
    exit 1
fi

printf "\n%.0s" {1..2}
