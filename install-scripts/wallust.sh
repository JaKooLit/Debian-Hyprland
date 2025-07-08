#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# wallust - pywal colors replacement #

wallust=(
    wallust
)
## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source Global_functions.sh"
    exit 1
}

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Set the name of the log file to include the current date and time
LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_wallust.log"

# Create log directory if it doesn't exist
mkdir -p "$(dirname "$LOG")"

# Install up-to-date Rust
echo "${INFO} Installing most ${YELLOW}up to date Rust compiler${RESET} ..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>&1 | tee -a "$LOG"
# shellcheck disable=SC1091
source "$HOME/.cargo/env"

newlines 2

# Remove any existing Wallust binary
if [[ -f "/usr/local/bin/wallust" ]]; then
    echo "Removing existing Wallust binary..." 2>&1 | tee -a "$LOG"
    remove_file "/usr/local/bin/wallust"
fi

newlines 2

# Install Wallust using Cargo
for WALL in "${wallust[@]}"; do
    if cargo_install "$WALL" "$LOG"; then
        echo "${OK} ${MAGENTA}Wallust${RESET} installed successfully." | tee -a "$LOG"
    else
        echo "${ERROR} Installation of ${MAGENTA}$WALL${RESET} failed. Check the log file $LOG for details." | tee -a "$LOG"
        exit 1
    fi
done
newlines 1
# Move the newly compiled binary to /usr/local/bin
echo "Moving Wallust binary to /usr/local/bin..." | tee -a "$LOG"
if sudo mv "$HOME/.cargo/bin/wallust" /usr/local/bin 2>&1 | tee -a "$LOG"; then
    echo "${OK} Wallust binary moved successfully to /usr/local/bin." | tee -a "$LOG"
else
    echo "${ERROR} Failed to move Wallust binary. Check the log file $LOG for details." | tee -a "$LOG"
    exit 1
fi

printf "\n%.0s" {1..2}
