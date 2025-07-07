#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Manual Stack Installer - Build entire Hyprland stack from source #
# Based on Hyprland wiki recommendations #

clear

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"

printf "\n%.0s" {1..2}  
echo -e "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││ MANUAL STACK
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘ Debian Build
\e[0m"
printf "\n%.0s" {1..1}

# Display warning message
echo -e "${WARNING}MANUAL STACK BUILD${RESET}: This will build the entire Hyprland stack from source."
echo -e "This follows the Hyprland wiki recommendation to build everything manually." 
echo -e "${WARNING}This process takes significantly longer but ensures latest compatibility.${RESET}"
echo
echo -e "${NOTE}Build process includes:${RESET}"
echo -e "  1. Base dependencies"
echo -e "  2. Wayland stack (wayland, wayland-protocols, libdisplay-info)"
echo -e "  3. Hypr dependencies (hyprutils, hyprlang, hyprcursor, aquamarine, etc.)"
echo -e "  4. Hyprland itself"
echo -e "  5. Additional components (hyprlock, hypridle, etc.)"
echo

# Prompt user to continue or exit
read -rp "Do you want to continue with the manual stack build? [y/N]: " confirm
case "$confirm" in
    [yY][eE][sS]|[yY])
        echo -e "${OK} Continuing with manual stack build..."
        ;;
    *)
        echo -e "${NOTE} You chose not to continue. Exiting..."
        exit 1
        ;;
esac

# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/01-Manual-Stack-Install-$(date +%d-%H%M%S).log"

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......." | tee -a "$LOG"
    printf "\n%.0s" {1..2} 
    exit 1
fi

# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="install-scripts/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            env "$script_path"
        else
            echo "Failed to make script '$script' executable." | tee -a "$LOG"
        fi
    else
        echo "Script '$script' not found in 'install-scripts'." | tee -a "$LOG"
    fi
}

echo "👌 ${OK} 🇵🇭 ${MAGENTA}KooL..${RESET} ${SKY_BLUE}Building entire stack manually...${RESET}" | tee -a "$LOG"

sleep 1
printf "\n%.0s" {1..1}

# Check compiler requirements
echo "${INFO} Checking ${SKY_BLUE}compiler requirements...${RESET}" | tee -a "$LOG"
gcc_version=$(gcc -dumpversion | cut -d. -f1)
if [ "$gcc_version" -lt 15 ]; then
    echo "${WARN} GCC version $gcc_version detected. Hyprland requires GCC >= 15 for C++26 support." | tee -a "$LOG"
    echo "${NOTE} Attempting to continue, but you may need a newer compiler..." | tee -a "$LOG"
fi

echo "${INFO} Installing ${SKY_BLUE}base dependencies for manual build...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "00-manual-stack-dependencies.sh"

echo "${INFO} Building ${SKY_BLUE}Wayland stack from source...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "01-manual-wayland-stack.sh"

echo "${INFO} Building ${SKY_BLUE}Hypr dependencies from source...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "02-manual-hypr-dependencies.sh"

echo "${INFO} Building ${SKY_BLUE}Hyprland from source...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "03-manual-hyprland.sh"

echo "${INFO} Building ${SKY_BLUE}additional Hypr components...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "hyprlock.sh"
sleep 1
execute_script "hypridle.sh"

clear
printf "\n%.0s" {1..2}

# Check if Hyprland was built successfully
if command -v Hyprland &> /dev/null; then
    printf "\n ${OK} 👌 Hyprland manual stack build completed successfully!"
    printf "\n${CAT} All components built from source as recommended by Hyprland wiki\n"
    sleep 2
    printf "\n%.0s" {1..2}

    printf "${SKY_BLUE}Thank you${RESET} 🫰 for using 🇵🇭 ${MAGENTA}KooL's Manual Hyprland Build${RESET}. ${YELLOW}Enjoy and Have a good day!${RESET}"
    printf "\n%.0s" {1..2}

    printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} (note the capital H!).\n"
    printf "\n${NOTE} It is ${YELLOW}highly recommended to reboot${RESET} your system for all library paths to be updated.\n\n"
    
    printf "\n${INFO} Manual build locations:${RESET}\n"
    printf "  - Libraries: /usr/local/lib\n"
    printf "  - Binaries: /usr/local/bin and /usr/bin\n"
    printf "  - Source builds: ~/hypr-source-builds\n\n"

    while true; do
        echo -n "${CAT} Would you like to reboot now? (y/n): "
        read HYP
        HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

        if [[ "$HYP" == "y" || "$HYP" == "yes" ]]; then
            echo "${INFO} Rebooting now..."
            systemctl reboot 
            break
        elif [[ "$HYP" == "n" || "$HYP" == "no" ]]; then
            echo "👌 ${OK} You chose NOT to reboot"
            printf "\n%.0s" {1..1}
            echo "${INFO} Remember to update your library paths or reboot before starting Hyprland"
            printf "\n%.0s" {1..1}
            break
        else
            echo "${WARN} Invalid response. Please answer with 'y' or 'n'."
        fi
    done
else
    # Print error message if Hyprland is not found
    printf "\n${WARN} Hyprland manual build may have failed. Please check the logs in Install-Logs/ directory..."
    printf "\n%.0s" {1..3}
    exit 1
fi

printf "\n%.0s" {1..2}