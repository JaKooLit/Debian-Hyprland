#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Fonts Required #

fonts=(
    fonts-firacode
    fonts-font-awesome
    fonts-noto
    fonts-noto-cjk
    fonts-noto-color-emoji
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

PARENT_DIR=$SCRIPT_DIR/..

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
LOG="$PARENT_DIR/Install-Logs/install-$(date +%d-%H%M%S)_fonts.log"

# Installation of main components
newlines 1
echo "${NOTE} - Installing necessary ${SKY_BLUE}fonts${RESET}...."

for PKG1 in "${fonts[@]}"; do
    install_package "$PKG1" "$LOG"
done

newlines 2

# jetbrains nerd font. Necessary for waybar
DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
# Maximum number of download attempts
MAX_ATTEMPTS=2
for ((ATTEMPT = 1; ATTEMPT <= MAX_ATTEMPTS; ATTEMPT++)); do
    curl -OL "$DOWNLOAD_URL" 2>&1 | tee -a "$LOG" && break
    echo "Download ${YELLOW}DOWNLOAD_URL${RESET} attempt $ATTEMPT failed. Retrying in 2 seconds..." 2>&1 | tee -a "$LOG"
    sleep 2
done

# Check if the JetBrainsMono directory exists and delete it if it does
remove_dir ~/.local/share/fonts/JetBrainsMonoNerd "$LOG"

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE}Not creating ~/.local/share/fonts/JetBrainsMonoNerd or extracting $PARENT_DIR/JetBrainsMonoNerd.tar.xz to that directory."
else
    mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd 2>&1 | tee -a "$LOG"
    # Extract the new files into the JetBrainsMono directory and log the output
    tar -xJkf "$PARENT_DIR"/JetBrainsMono.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerd 2>&1 | tee -a "$LOG"
fi

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE} Not installing Fantasque Mono Nerd Font."
else
    # Fantasque Mono Nerd Font
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FantasqueSansMono.zip; then
        mkdir -p "$HOME/.local/share/fonts/FantasqueSansMonoNerd" && unzip -o -q "FantasqueSansMono.zip" -d "$HOME/.local/share/fonts/FantasqueSansMono" && echo "FantasqueSansMono installed successfully" | tee -a "$LOG"
    else
        echo -e "\n${ERROR} Failed to download ${YELLOW}Fantasque Sans Mono Nerd Font${RESET} Please check your connection\n" | tee -a "$LOG"
    fi
fi

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE} Not installing Victor Mono-Font"
else
    # Victor Mono-Font
    if wget -q https://rubjo.github.io/victor-mono/VictorMonoAll.zip; then
        mkdir -p "$HOME/.local/share/fonts/VictorMono" && unzip -o -q "VictorMonoAll.zip" -d "$HOME/.local/share/fonts/VictorMono" && echo "Victor Font installed successfully" | tee -a "$LOG"
    else
        echo -e "\n${ERROR} Failed to download ${YELLOW}Victor Mono Font${RESET} Please check your connection\n" | tee -a "$LOG"
    fi
fi

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE}Not updating the font cache with fc-cache"
else
    # Update font cache and log the output
    fc-cache -v 2>&1 | tee -a "$LOG"
fi

# clean up
remove_file "$PARENT_DIR"/JetBrainsMono.tar.xz "$LOG"

newlines 2
