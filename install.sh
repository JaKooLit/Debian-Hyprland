#!/bin/bash
# https://github.com/JaKooLit

# Do not complain about the following message in this file:
#  Don't use variables in the printf format string. Use printf "..%s.." "$foo".
# Rationale: I want nice color formatting in printf.
# shellcheck disable=2059

# Let's be safer when programming in Bash
set -euo pipefail
IFS=$'\n\t'

PARENT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

cd "$PARENT_DIR" || (echo "Failed to change directory to $PARENT_DIR, so exitting with error code 1." && exit 1)

# Set the name of the log file to include the current date and time
LOG="$PARENT_DIR/Install-Logs/01-Hyprland-Install-Scripts-$(date +%d-%H%M%S).log"

restore_cursor() {
    tput cnorm
    [[ $(type -t verbose_log) == "function" && -v VERBOSE ]] && verbose_log "Exiting, so restoring cursor in case 'tput civis' was executed."
}

cleanup() {
    restore_cursor
    echo -e "\n\n$1" | tee -a "$LOG"
    exit 1
}

# In case user interrupts, switch back to old directory. Manually set colors for compatibility.
trap 'restore_cursor' EXIT
trap 'cleanup "$(tput setaf 4)[INFO]$(tput sgr0) Exiting by error encountered. (ERR)...\n$(tput setaf 251)[NOTE]$(tput sgr0) If you did not press Ctrl+D, check the most recent files in $PARENT_DIR/Install-Logs for possible reasons for such an early exit."' ERR
trap 'cleanup "$(tput setaf 12)[ACTION]$(tput sgr0) Exiting due to user-interrupt. (SIGINT)..."' SIGINT
trap 'cleanup "$(tput setaf 1)[ERROR]$(tput sgr0) Exiting due to abort signal. A critical error may have occurred internally. (SIGABRT)..."' SIGABRT

source "$PARENT_DIR/install-scripts/colors.sh" || {
    echo "$(tput setaf 1)[ERROR]$(tput sgr0) Failed to source $PARENT_DIR/install-scripts/colors.sh" | tee -a "$LOG"
    exit 1
}

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR} This script should ${RED}NOT${RESET} be executed as root!! Exiting......." | tee -a "$LOG"
    printf "\n%.0s" {1..2}
    exit 1
fi

source "$PARENT_DIR/install-scripts/Global_functions.sh" || {
    echo "${ERROR} Failed to source $PARENT_DIR/install-scripts/Global_functions.sh" | tee -a "$LOG"
    exit 1
}

parse_args "$@"

# Display warning message
echo "${WARNING}WARNING:${RESET} Hyprland on Repo is extremely outdated and will not be supported anymore."
echo "Use this at your own risk."
echo "${RED}Any issues will not be dealt with${RESET}"
newlines 1

# Prompt user to continue or exit
read -rp "Do you want to continue with the installation? [y/N]: " confirm
case "$confirm" in
[yY][eE][sS] | [yY])
    echo "${OK} Continuing with installation..."
    ;;
*)
    echo "${INFO} You chose not to continue. Exiting..."
    exit 1
    ;;
esac

# Check if the system is Ubuntu
if is_ubuntu; then
    echo "${WARN}This script is ${RED}NOT intended for an Ubuntu / Ubuntu-based distribution${RESET}. Refer to ${YELLOW}README for the correct link for the Ubuntu-Hyprland project${RESET}" | tee -a "$LOG"
    exit 1
else
    verbose_log "You are not using an Ubuntu / Ubuntu-based distribution."
fi

# install whiptails if detected not installed. Necessary for this version
if ! command -v whiptail >/dev/null; then
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I won't install whiptail even though it is required." | tee -a "$LOG"
    else
        echo "${NOTE} - whiptail is not installed. Installing..." | tee -a "$LOG"
        apt_install whiptail
    fi
    newlines 1
else
    verbose_log "whiptail already installed, not installing."
fi

newlines 2
echo -e "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││ 2025
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘ Debian Trixie / SiD
\e[0m"
newlines 1

# Welcome message using whiptail (for displaying information)
whiptail --title "KooL Debian-Hyprland Trixie-SID (2025) Install Script" \
    --msgbox "Welcome to KooL Debian-Hyprland Trixie-SID (2025) Install Script!!!\n\n\
ATTENTION: Run a full system update and Reboot first !!! (Highly Recommended)\n\n\
NOTE: If you are installing on a VM, ensure to enable 3D acceleration else Hyprland may NOT start!" \
    15 80

# Ask if the user wants to proceed
if ! whiptail --title "Proceed with Installation?" \
    --yesno "VERY IMPORTANT!!!\n\nYou must be able to install from source by uncommenting deb-src on /etc/apt/sources.list else script may fail to install Hyprland.\n\n\nShall we proceed?" 15 60; then
    newlines 2
    echo "❌ ${INFO} You 🫵 chose ${YELLOW}NOT${RESET} to proceed. ${YELLOW}Exiting...${RESET}" | tee -a "$LOG"
    newlines 2
    exit 1
fi

echo "👌 ${OK} 🇵🇭 ${MAGENTA}KooL..${RESET} ${SKY_BLUE}let's continue with the installation...${RESET}" | tee -a "$LOG"

sleep 1
newlines 1

# install pciutils if detected not installed. Necessary for detecting GPU
if ! dpkg -l | grep -w pciutils >/dev/null; then
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I won't install whiptail even though it is required." | tee -a "$LOG"
    else
        echo "pciutils is not installed. Installing..." | tee -a "$LOG"
        apt_install pciutils
    fi
    newlines 1
else
    verbose_log "pciutils already installed, not installing."
fi

#################
## Default values for the options (will be overwritten by preset file if --preset is used with a valid file)
export gtk_themes="OFF"
export bluetooth="OFF"
export thunar="OFF"
export ags="OFF"
export sddm="OFF"
export sddm_theme="OFF"
export xdph="OFF"
export zsh="OFF"
export pokemon="OFF"
export rog="OFF"
export dots="OFF"
export input_group="OFF"
export nvidia="OFF"

# Load preset if PRESET_ENABLED is 1, which is only if PRESET is a valid file and set as an argument
if [[ $PRESET_ENABLED -eq 1 ]]; then
    # shellcheck disable=SC2153
    load_preset "$PRESET"
fi

check_services_running
# shellcheck disable=SC2034
NON_SDDM_SERVICES_RUNNING=$?

if [[ $NON_SDDM_SERVICES_RUNNING -eq 1 ]]; then
    active_list=$(printf "%s\n" "${active_services[@]}")

    # Display the active login manager(s) in the whiptail message box
    whiptail --title "Active non-SDDM login manager(s) detected" \
        --msgbox "The following login manager(s) are active:\n\n$active_list\n\nIf you want to install SDDM and SDDM theme, stop and disable first the active services above, and reboot before running this script\nRefer to README on switching to SDDM if you really want SDDM\n\nNOTE: Your option to install SDDM and SDDM theme has now been removed\n\n- Ja " 28 80
fi

# Check if NVIDIA GPU is detected
nvidia_detected=false
if lspci | grep -i "nvidia" &>/dev/null; then
    verbose_log "NVIDIA GPU detected."
    nvidia_detected=true
    whiptail --title "NVIDIA GPU Detected" --msgbox "NVIDIA GPU detected in your system.\n\nNOTE: The script will install nvidia-dkms, nvidia-utils, and nvidia-settings if you choose to configure." 12 60
else
    verbose_log "NVIDIA GPU not detected."
fi

# Initialize the options array for whiptail checklist
options_command=(
    whiptail --title "Select Options" --checklist "Choose options to install or configure\nNOTE: 'SPACEBAR' to select & 'TAB' key to change selection" 28 85 20
)

# Add NVIDIA options if detected
if [ "$nvidia_detected" == "true" ]; then
    verbose_log "Adding nvidia option to selection list"
    options_command+=(
        "nvidia" "Do you want script to configure NVIDIA GPU?" "OFF"
    )
fi

# Check if user is already in the 'input' group
input_group_detected=false
if ! groups "$(whoami)" | grep -q '\binput\b'; then
    verbose_log "You are not in the input group."
    input_group_detected=true
    whiptail --title "Input Group" --msgbox "You are not currently in the input group.\n\nAdding you to the input group might be necessary for the Waybar keyboard-state functionality." 12 60
else
    verbose_log "You are already in the input group."
fi

# Add 'input_group' option if user is not in input group
if [[ "$input_group_detected" == "true" ]]; then
    verbose_log "Adding input_group option to selection list"
    options_command+=(
        "input_group" "Add your USER to input group for some waybar functionality?" "OFF"
    )
fi

# Conditionally add SDDM and SDDM theme options if no active login manager is found
if [[ $NON_SDDM_SERVICES_RUNNING -eq 0 ]]; then
    options_command+=(
        "sddm" "Install & configure SDDM login manager?" "OFF"
        "sddm_theme" "Download & Install Additional SDDM theme?" "OFF"
    )
fi

verbose_log "Adding remaining gtk_themes, bluetooth, thunar, ags, xdph, zsh, pokemon, rog, and dots options to selection"
# Add the remaining static options
options_command+=(
    "gtk_themes" "Install GTK themes (required for Dark/Light function)" "OFF"
    "bluetooth" "Do you want script to configure Bluetooth?" "OFF"
    "thunar" "Do you want Thunar file manager to be installed?" "OFF"
    "ags" "Install AGS v1 for Desktop-Like Overview" "OFF"
    "xdph" "Install XDG-DESKTOP-PORTAL-HYPRLAND (for screen share)?" "OFF"
    "zsh" "Install zsh shell with Oh-My-Zsh?" "OFF"
    "pokemon" "Add Pokemon color scripts to your terminal?" "OFF"
    "rog" "Are you installing on Asus ROG laptops?" "OFF"
    "dots" "Download and install pre-configured KooL Hyprland dotfiles?" "OFF"
)

# Capture the selected options before the while loop starts
while true; do
    # Check if the user pressed Cancel (exit status 1)
    if ! selected_options=$("${options_command[@]}" 3>&1 1>&2 2>&3); then
        newlines 2
        echo "❌ ${INFO} You 🫵 cancelled the selection. ${YELLOW}Goodbye!${RESET}" | tee -a "$LOG"
        exit 0 # Exit the script if Cancel is pressed
    fi

    # If no option was selected, notify and restart the selection
    if [ -z "$selected_options" ]; then
        verbose_log "No options selected."
        whiptail --title "Warning" --msgbox "No options were selected. Please select at least one option." 10 60
        continue # Return to selection if no options selected
    fi

    # Strip the quotes and trim spaces if necessary (sanitize the input)
    selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')

    # Convert selected options into an array (preserving spaces in values)
    IFS=' ' read -r -a options <<<"$selected_options"

    # Check if the "dots" option was selected
    dots_selected="OFF"
    for option in "${options[@]}"; do
        if [[ "$option" == "dots" ]]; then
            verbose_log "dots option selected"
            dots_selected="ON"
            break
        fi
    done

    # If "dots" is not selected, show a note and ask the user to proceed or return to choices
    if [[ "$dots_selected" == "OFF" ]]; then
        # Show a note about not selecting the "dots" option
        if ! whiptail --title "KooL Hyprland Dot Files" --yesno \
            "You have not selected to install the pre-configured KooL Hyprland dotfiles.\n\nKindly NOTE that if you proceed without Dots, Hyprland will start with default vanilla Hyprland configuration and I won't be able to give you support.\n\nWould you like to continue install without KooL Hyprland Dots or return to choices/options?" \
            --yes-button "Continue" --no-button "Return" 15 90; then
            echo "🔙 Returning to options..." | tee -a "$LOG"
            continue
        else
            # User chose to continue
            echo "${INFO} ⚠️ Continuing WITHOUT the dotfiles installation..." | tee -a "$LOG"
            newlines 1
        fi
    fi

    # Prepare the confirmation message
    confirm_message="You have selected the following options:\n\n"
    for option in "${options[@]}"; do
        confirm_message+=" - $option\n"
    done
    confirm_message+="\nAre you happy with these choices?"

    # Confirmation prompt
    if ! whiptail --title "Confirm Your Choices" --yesno "$(printf "%s" "$confirm_message")" 25 80; then
        newlines 2
        echo "❌ ${SKY_BLUE}You're not 🫵 happy${RESET}. ${YELLOW}Returning to options...${RESET}" | tee -a "$LOG"
        continue
    fi

    echo "👌 ${OK} You confirmed your choices. Proceeding with ${SKY_BLUE}KooL 🇵🇭 Hyprland Installation...${RESET}" | tee -a "$LOG"
    break
done

newlines 1

if [[ $PEDANTIC_DRY -eq 1 ]]; then
    echo "${NOTE} I won't synchronize your package index files." | tee -a "$LOG"
else
    echo "${INFO} ${SKY_BLUE}Synchronizing${RESET} package index files with apt update..." | tee -a "$LOG"
    sudo apt update
fi

sleep 1
# execute pre clean up
execute_script "02-pre-cleanup.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary dependencies...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "00-dependencies.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "fonts.sh"

echo "${INFO} Installing ${SKY_BLUE}KooL Hyprland packages...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "01-hypr-pkgs.sh"
sleep 1
execute_script "hyprland.sh"
sleep 1
execute_script "wallust.sh"
sleep 1
execute_script "swww.sh"
sleep 1
execute_script "rofi-wayland.sh"

#execute_script "imagemagick.sh" #this is for compiling from source. 07 Sep 2024
# execute_script "waybar-git.sh" only if waybar on repo is old

sleep 1
# Clean up the selected options (remove quotes and trim spaces)
selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')

# Convert selected options into an array (splitting by spaces)
IFS=' ' read -r -a options <<<"$selected_options"

# Loop through selected options
for option in "${options[@]}"; do
    case "$option" in
    sddm)
        if check_services_running; then
            active_list=$(printf "%s\n" "${active_services[@]}")
            whiptail --title "Error" --msgbox "One of the following login services is running:\n$active_list\n\nPlease stop & disable it or DO not choose SDDM." 12 60
            exec "$0"
        else
            echo "${INFO} Installing and configuring ${SKY_BLUE}SDDM...${RESET}" | tee -a "$LOG"
            execute_script "sddm.sh"
        fi
        ;;
    nvidia)
        echo "${INFO} Configuring ${SKY_BLUE}nvidia stuff${RESET}" | tee -a "$LOG"
        execute_script "nvidia.sh"
        ;;
    gtk_themes)
        echo "${INFO} Installing ${SKY_BLUE}GTK themes...${RESET}" | tee -a "$LOG"
        execute_script "gtk_themes.sh"
        ;;
    input_group)
        echo "${INFO} Adding user into ${SKY_BLUE}input group...${RESET}" | tee -a "$LOG"
        execute_script "InputGroup.sh"
        ;;
    ags)
        echo "${INFO} Installing ${SKY_BLUE}AGS v1 for Desktop Overview...${RESET}" | tee -a "$LOG"
        execute_script "ags.sh"
        ;;
    xdph)
        echo "${INFO} Installing ${SKY_BLUE}xdg-desktop-portal-hyprland...${RESET}" | tee -a "$LOG"
        execute_script "xdph.sh"
        ;;
    bluetooth)
        echo "${INFO} Configuring ${SKY_BLUE}Bluetooth...${RESET}" | tee -a "$LOG"
        execute_script "bluetooth.sh"
        ;;
    thunar)
        echo "${INFO} Installing ${SKY_BLUE}Thunar file manager...${RESET}" | tee -a "$LOG"
        execute_script "thunar.sh"
        execute_script "thunar_default.sh"
        ;;
    sddm_theme)
        echo "${INFO} Downloading & Installing ${SKY_BLUE}Additional SDDM theme...${RESET}" | tee -a "$LOG"
        execute_script "sddm_theme.sh"
        ;;
    zsh)
        echo "${INFO} Installing ${SKY_BLUE}zsh with Oh-My-Zsh...${RESET}" | tee -a "$LOG"
        execute_script "zsh.sh"
        ;;
    pokemon)
        echo "${INFO} Adding ${SKY_BLUE}Pokemon color scripts to terminal...${RESET}" | tee -a "$LOG"
        execute_script "zsh_pokemon.sh"
        ;;
    rog)
        echo "${INFO} Installing ${SKY_BLUE}ROG laptop packages...${RESET}" | tee -a "$LOG"
        execute_script "rog.sh"
        ;;
    dots)
        echo "${INFO} Installing pre-configured ${SKY_BLUE}KooL Hyprland dotfiles...${RESET}" | tee -a "$LOG"
        execute_script "dotfiles-branch.sh"
        ;;
    *)
        echo "Unknown option: $option" | tee -a "$LOG"
        ;;
    esac
done

# Perform cleanup
printf "\n${OK} Performing some clean up.\n"
verbose_log "Checking to remove files $WORKING_DIR/JetBrainsMono.tar.xz, $WORKING_DIR/VictorMonoAll.zip, and $WORKING_DIR/FantasqueSansMono.zip"
files_to_delete=("JetBrainsMono.tar.xz" "VictorMonoAll.zip" "FantasqueSansMono.zip")
for file in "${files_to_delete[@]}"; do
    if [ -e "$file" ]; then
        if [[ $DRY -eq 1 ]]; then
            echo "I am not deleting $file even though it should be cleaned up. Manually use 'rm $file' instead." | tee -a "$LOG"
        else
            echo "$file found. Deleting..." | tee -a "$LOG"
            rm "$file"
            echo "$file deleted successfully." | tee -a "$LOG"
        fi
    fi
done

# clear

# copy fastfetch config if debian is not present
if [ ! -f "$HOME/.config/fastfetch/debian.png" ]; then
    if [[ $DRY -eq 1 ]]; then
        echo "${NOTE} I am not copying $WORKING_DIR/assets/fastfetch to $HOME/.config" | tee -a "$LOG"
    else
        verbose_log "Copying $WORKING_DIR/assets/fastfetch to $HOME/.config/ since $HOME/.config/fastfetch/debian.png is not present"
        cp -r assets/fastfetch "$HOME/.config/"
    fi
fi

newlines 2
# final check essential packages if it is installed
execute_script "03-Final-Check.sh"

newlines 1

# Check if hyprland is installed, either by apt, which is installing via apt is not supported and therefore impossible, or by building from source, which is to check if some other possible location exists with command -v
if check_if_installed_with_apt "hyprland" || command -v Hyprland >/dev/null; then
    if check_if_installed_with_apt "hyprland"; then
        verbose_log "hyprland is installed with apt"
    else
        verbose_log "hyprland is not installed with apt, but since the command, Hyprland, exists, I assume hyprland was built and installed from source"
    fi
    printf "\n ${OK} 👌 Hyprland is installed. However, some essential packages may not be installed. Please see above!"
    printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
    sleep 2
    newlines 2

    printf "${SKY_BLUE}Thank you${RESET} 🫰 for using 🇵🇭 ${MAGENTA}KooL's Hyprland Dots${RESET}. ${YELLOW}Enjoy and Have a good day!${RESET}"
    newlines 2

    printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} or ${SKY_BLUE}hyprland${RESET} (IF SDDM is not installed).\n"
    printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

    while true; do
        echo -n "${CAT} Would you like to reboot now? (y/n): "
        read -r HYP
        HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

        if [[ "$HYP" == "y" || "$HYP" == "yes" ]]; then
            if [[ $PEDANTIC_DRY -eq 1 ]]; then
                echo "${NOTE} Not rebooting, even with user confirmation, since pedantic dry run mode is enabled. However, you can still manually reboot with 'systemctl reboot'." | tee -a "$LOG"
                break
            fi
            echo "${INFO} Rebooting now..." | tee -a "$LOG"
            systemctl reboot
            break
        elif [[ "$HYP" == "n" || "$HYP" == "no" ]]; then
            echo "👌 ${OK} You chose NOT to reboot" | tee -a "$LOG"
            newlines 1
            # Check if NVIDIA GPU is present
            if lspci | grep -i "nvidia" &>/dev/null; then
                echo "${INFO} HOWEVER ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..." | tee -a "$LOG"
                newlines 1
            fi
            break
        else
            echo "${WARN} Invalid response. Please answer with 'y' or 'n'."
        fi
    done
else
    # Print error message if neither package is installed
    printf "\n${WARN} Hyprland is NOT installed. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory..." | tee -a "$LOG"
    newlines 3
    verbose_log "I shall exit with error code 1 since hyprland is probably not installed based on checking apt and /usr/bin for hyprland"
    exit 1
fi

newlines 2
