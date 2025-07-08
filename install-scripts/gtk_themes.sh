#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# GTK Themes & ICONS and  Sourcing from a different Repo #

engine=(
    unzip
    gtk2-engines-murrine
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."

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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_themes.log"

# installing engine needed for gtk themes
verbose_log "Installing dependencies for gtk themes"
for PKG1 in "${engine[@]}"; do
    install_package "$PKG1" "$LOG"
done

# Check if the directory exists and delete it if present
remove_dir "GTK-themes-icons"

echo "$NOTE Cloning ${SKY_BLUE}GTK themes and Icons${RESET} repository..." 2>&1 | tee -a "$LOG"
if [[ $NO_BUILD -eq 1 ]]; then
    echo "${NOTE} Not cloning or building https://github.com/JaKooLit/GTK-themes-icons.git"
else
    if git clone --depth=1 https://github.com/JaKooLit/GTK-themes-icons.git; then
        (
            cd GTK-themes-icons || exit 1
            if [[ $PEDANTIC_DRY -eq 1 ]]; then
                echo "${NOTE} Not running auto-extract.sh or setting it to be executable as we do not want to modify files"
            else
                chmod +x auto-extract.sh
                ./auto-extract.sh
            fi
        )
        echo "$OK Extracted GTK Themes & Icons to ~/.icons & ~/.themes directories" 2>&1 | tee -a "$LOG"
    else
        echo "$ERROR Download failed for GTK themes and Icons.." 2>&1 | tee -a "$LOG"
    fi
fi

newlines 2
