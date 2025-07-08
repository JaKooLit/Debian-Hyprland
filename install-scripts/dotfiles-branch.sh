#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Hyprland-Dots to download from main #

#specific branch or release
dots_tag="Deb-Untu-Dots"

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."

cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Source the global functions script
source "$SCRIPT_DIR/Global_functions.sh" || {
    echo "Failed to source $SCRIPT_DIR/Global_functions.sh"
    exit 1
}

# Check if Hyprland-Dots exists
echo "${NOTE} Cloning and Installing ${SKY_BLUE}KooL's Hyprland Dots for Debian${RESET}...."

# Check if Hyprland-Dots exists
if [ -d Hyprland-Dots-Debian ]; then
    cd Hyprland-Dots-Debian || exit
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I am not stashing and pulling the already existing $PARENT_DIR/Hyprland-Dots-Debian directory or copying KooL's Hyprland Dots."
    else
        git stash && git pull
        chmod +x copy.sh
        ./copy.sh
    fi
else
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I am not fetching KooL's Hyprland-Dots-Debian repository or copying those files."
    else
        if git clone --depth=1 -b $dots_tag https://github.com/JaKooLit/Hyprland-Dots Hyprland-Dots-Debian; then
            cd Hyprland-Dots-Debian || exit 1
            chmod +x copy.sh
            ./copy.sh
        else
            echo -e "$ERROR Can't download ${YELLOW}KooL's Hyprland-Dots-Debian${RESET}"
        fi
    fi
fi

newlines 2
