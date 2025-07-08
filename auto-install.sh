#!/bin/bash
# https://github.com/JaKooLit

# Set some colors for output messages
export MAGENTA="$(tput setaf 5)"
export YELLOW="$(tput setaf 226)"
export RED="$(tput setaf 1)"
export ORANGE="$(tput setaf 3)"
export GREEN="$(tput setaf 2)"
export BLUE="$(tput setaf 4)"
export SKY_BLUE="$(tput setaf 12)"
export GRAY="$(tput setaf 251)"
export GREY=$GRAY
export WARNING=$ORANGE
export RESET="$(tput sgr0)"
export OK="${GREEN}[OK]${RESET}"
export ERROR="${RED}[ERROR]${RESET}"
export NOTE="${GRAY}[NOTE]${RESET}"
export INFO="${BLUE}[INFO]${RESET}"
export WARN="${WARNING}[WARN]${RESET}"
export CAT="${SKY_BLUE}[ACTION]${RESET}"

# Variables
Distro="Debian-Hyprland"
Github_URL="https://github.com/JaKooLit/$Distro.git"
Distro_DIR="$HOME/$Distro"

printf "\n%.0s" {1..1}

if ! command -v git &>/dev/null; then
    echo "${INFO} Git not found! ${SKY_BLUE}Installing Git...${RESET}"
    if ! sudo apt install --assume-yes git; then
        echo "${ERROR} Failed to install Git. Exiting."
        exit 1
    fi
fi

printf "\n%.0s" {1..1}

if [ -d "$Distro_DIR" ]; then
    echo "${YELLOW}$Distro_DIR exists. Updating the repository... ${RESET}"
    cd "$Distro_DIR" || exit 1
    git stash && git pull
    chmod +x install.sh
    ./install.sh
else
    echo "${MAGENTA}$Distro_DIR does not exist. Cloning the repository...${RESET}"
    git clone --depth=1 "$Github_URL" "$Distro_DIR"
    cd "$Distro_DIR" || exit 1
    chmod +x install.sh
    ./install.sh
fi
