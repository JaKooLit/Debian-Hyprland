#!/bin/bash
# https://github.com/JaKooLit


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

# Function to print colorful text
print_color() {
    printf "%b%s%b\n" "$1" "$2" "$RESET"
}

print_help() {
    cat <<EOF
KooL Debian-Hyprland installer
Usage: ${0##*/} [OPTIONS]

Options:
  --build-trixie         Force trixie compatibility mode
  --no-trixie           Disable trixie compatibility mode
  --preset <file>       Load preset file with options
  --force-reinstall     Force APT re-installs where applicable
  --tty                 Use simple TTY prompts instead of whiptail dialogs
  -h, --help            Show this help and exit

Notes:
  --tty is a fallback for remote/CI or when terminals cannot render whiptail.
  XDG-Desktop-Portal-Hyprland (screen sharing) is installed by default.
EOF
}

# ---------------- APT source checks (deb-src, non-free, non-free-firmware) ----------------
_detect_codename() {
    local c
    if [ -r /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release 2>/dev/null || true
        c="${DEBIAN_CODENAME:-${VERSION_CODENAME:-}}"
    fi
    if [ -z "$c" ]; then c=$(lsb_release -c -s 2>/dev/null || true); fi
    if [ -z "$c" ]; then c="trixie"; fi
    echo "$c"
}

_has_deb_src_enabled() {
    sudo grep -RhsE '^[[:space:]]*deb-src[[:space:]]' /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | grep -q .
}

_has_component_enabled() {
    # $1: component (e.g., non-free, non-free-firmware)
    local comp="$1"
    sudo grep -RhsE "^[[:space:]]*deb(-src)?[[:space:]].*\\b${comp}(\\s|$)" /etc/apt/sources.list /etc/apt/sources.list.d/*.list 2>/dev/null | grep -q .
}

_enable_deb_src_conservatively() {
    local f=/etc/apt/sources.list
    # First try to uncomment any commented deb-src lines in the main list
    sudo sed -i -E 's/^[[:space:]]*#([[:space:]]*deb-src[[:space:]])/\1/' "$f" 2>/dev/null || true

    if ! _has_deb_src_enabled; then
        # If still none present, duplicate active deb lines into deb-src lines
        local tmp
        tmp=$(mktemp)
        sudo awk '
            BEGIN { added=0 }
            /^[[:space:]]*deb[[:space:]]/ && $0 !~ /^[[:space:]]*#/ {
                line=$0; sub(/^([[:space:]]*)deb/, "\\1deb-src", line); print $0; print line; added=1; next
            }
            { print $0 }
            END { if (added==0) {} }
        ' "$f" > "$tmp" && sudo cp "$tmp" "$f" && rm -f "$tmp"
    fi
}

_write_nonfree_overlay_sources() {
    # Create a small overlay sources file that only enables the missing components
    local c suite upd sec file
    c=$(_detect_codename)
    suite="$c"
    upd="${c}-updates"
    sec="${c}-security"
    file="/etc/apt/sources.list.d/99-debian-nonfree.list"

    sudo bash -c "cat > '$file' <<EOF
# Added by Debian-Hyprland installer to ensure non-free components are available
# Safe overlay: does not modify existing sources.list; can be removed later if undesired.
deb http://deb.debian.org/debian ${suite} non-free non-free-firmware
deb-src http://deb.debian.org/debian ${suite} non-free non-free-firmware
EOF" 

    # For non-sid suites, add updates and security pockets
    if [ "$c" != "sid" ]; then
        sudo bash -c "cat >> '$file' <<EOF
deb http://deb.debian.org/debian ${upd} non-free non-free-firmware
deb-src http://deb.debian.org/debian ${upd} non-free non-free-firmware
deb http://security.debian.org/debian-security ${sec} non-free non-free-firmware
deb-src http://security.debian.org/debian-security ${sec} non-free non-free-firmware
EOF"
    fi
}

verify_and_offer_fix_apt_sources() {
    local need_fix=0
    local msg=""

    if _has_deb_src_enabled; then
        msg+="\n - deb-src: ${GREEN}ENABLED${RESET}"
    else
        msg+="\n - deb-src: ${YELLOW}MISSING${RESET}"
        need_fix=1
    fi

    if _has_component_enabled non-free; then
        msg+="\n - non-free: ${GREEN}ENABLED${RESET}"
    else
        msg+="\n - non-free: ${YELLOW}MISSING${RESET}"
        need_fix=1
    fi

    if _has_component_enabled non-free-firmware; then
        msg+="\n - non-free-firmware: ${GREEN}ENABLED${RESET}"
    else
        msg+="\n - non-free-firmware: ${YELLOW}MISSING${RESET}"
        need_fix=1
    fi

    echo -e "${INFO} APT sources status:${msg}"

    if [ "$need_fix" -eq 1 ]; then
        if command -v whiptail >/dev/null 2>&1; then
            if whiptail --title "APT sources not fully enabled" --yesno "deb-src and/or non-free components are missing.\n\nEnable now by:\n - Uncommenting or adding deb-src lines\n - Adding a small overlay sources file to enable non-free and non-free-firmware\n\nProceed?" 17 70; then
                _enable_deb_src_conservatively
                _write_nonfree_overlay_sources
            else
                echo -e "${WARN} Required APT sources not enabled. Some build steps may fail."
            fi
        else
            echo -e "${WARN} Required APT sources not enabled. Install whiptail to allow auto-fix or edit /etc/apt/sources.list manually."
        fi
    fi
}

# Warning: End of Life Support
printf "\n%.0s" {1..2}
print_color $YELLOW "
        █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
              KooL's Debian - Hyprland October 2025 Update
              
            Most Hyprland packages are built from Source

                                NOTICE
        █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

    All Hyprland and associated packages set to install using this script are downloaded and built from source (github)
    
    However, do note that it is downloaded from each individual releases. You can set versions by editing the scripts
    located install-scripts directory.

    These packages are NOT updated automatically. 

    See the HOWTO documentation on how to get next release of Hyprland installed 
    
    BE WARNED!!!!!  Installation will take longer!!


        █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
              
                                NOTE:
                    Hyprland and Dependencies versions              

        █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

    
    Thank you!
"
printf "\n%.0s" {1..2}

# Prompt user to continue or exit
read -rp "Do you want to continue with the installation? [y/N]: " confirm
case "$confirm" in
[yY][eE][sS] | [yY])
    echo -e "${OK} Continuing with installation..."
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
LOG="Install-Logs/01-Hyprland-Install-Scripts-$(date +%d-%H%M%S).log"

# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......." | tee -a "$LOG"
    printf "\n%.0s" {1..2}
    exit 1
fi

# Function to check if the system is Ubuntu
is_ubuntu() {
    # Check for 'Ubuntu' in /etc/os-release
    if grep -q 'Ubuntu' /etc/os-release; then
        return 0
    fi
    return 1
}

# Check if the system is Ubuntu
if is_ubuntu; then
    echo "${WARN}This script is ${WARNING}NOT intended for Ubuntu / Ubuntu Based${RESET}. Refer to ${YELLOW}README for the correct link for Ubuntu-Hyprland project${RESET}" | tee -a "$LOG"
    exit 1
fi

# Debian Trixie compatibility mode
# Some Hypr* components need source-level shims on Debian 13 (trixie) toolchains.
# Default: auto-detect via /etc/os-release
# Overrides:
#   --build-trixie / --no-trixie
#   HYPR_BUILD_TRIXIE=1|0 (env)
TRIXIE_MODE="auto"
PRESET_FILE=""

# Parse a small set of supported CLI args (order-independent)
# NOTE: install.sh historically used "$1"/"$2" for --preset; this keeps that working.
args=("$@")
FORCE_REINSTALL=0
TTY_MODE=0
for ((i=0; i<${#args[@]}; i++)); do
    case "${args[$i]}" in
        --build-trixie)
            TRIXIE_MODE="on"
            ;;
        --no-trixie)
            TRIXIE_MODE="off"
            ;;
        --force-reinstall)
            FORCE_REINSTALL=1
            ;;
        --tty)
            TTY_MODE=1
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        --preset)
            if [ $((i+1)) -lt ${#args[@]} ]; then
                PRESET_FILE="${args[$((i+1))]}"
            fi
            ;;
    esac
 done

# If env explicitly sets HYPR_BUILD_TRIXIE, honor it.
if [ -n "${HYPR_BUILD_TRIXIE+x}" ]; then
    if [ "${HYPR_BUILD_TRIXIE}" = "1" ]; then
        TRIXIE_MODE="on"
    elif [ "${HYPR_BUILD_TRIXIE}" = "0" ]; then
        TRIXIE_MODE="off"
    fi
fi

# Resolve auto-detection
if [ "$TRIXIE_MODE" = "auto" ]; then
    HYPR_BUILD_TRIXIE=0
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release || true
        if [ "${ID:-}" = "debian" ] && [ "${VERSION_CODENAME:-}" = "trixie" ]; then
            HYPR_BUILD_TRIXIE=1
        fi
    fi
elif [ "$TRIXIE_MODE" = "on" ]; then
    HYPR_BUILD_TRIXIE=1
else
    HYPR_BUILD_TRIXIE=0
fi
export HYPR_BUILD_TRIXIE

# Install whiptail unless running in --tty mode
if [ "$TTY_MODE" -ne 1 ] && ! command -v whiptail >/dev/null; then
    echo "${NOTE} - whiptail is not installed. Installing..." | tee -a "$LOG"
    sudo apt install -y whiptail
    printf "\n%.0s" {1..1}
fi

printf "\n%.0s" {1..2}
echo -e "\e[35m
	╦╔═┌─┐┌─┐╦    ╦ ╦┬ ┬┌─┐┬─┐┬  ┌─┐┌┐┌┌┬┐
	╠╩╗│ ││ │║    ╠═╣└┬┘├─┘├┬┘│  ├─┤│││ ││ July 2025
	╩ ╩└─┘└─┘╩═╝  ╩ ╩ ┴ ┴  ┴└─┴─┘┴ ┴┘└┘─┴┘ Debian Trixie / SiD
\e[0m"
printf "\n%.0s" {1..1}

# Function to clean up existing Hyprland installations
clean_existing_hyprland() {
    echo "${INFO} Checking for existing Hyprland installations..." | tee -a "$LOG"
    
    # List of Hyprland-related packages and binaries to check
    local hyprland_packages=("hyprland" "hyprutils" "hyprgraphics" "hyprcursor" "hyprtoolkit" "hyprland-guiutils" "hyprwire" "aquamarine" "hypridle" "hyprlock" "hyprpolkitagent" "hyprpicker" "xdg-desktop-portal-hyprland" "hyprland-plugins")
    local hyprland_binaries=("/usr/local/bin/Hyprland" "/usr/local/bin/hyprland" "/usr/bin/Hyprland" "/usr/bin/hyprland")
    
    # Remove installed .deb packages
    echo "${INFO} Removing any previously installed .deb packages..." | tee -a "$LOG"
    for pkg in "${hyprland_packages[@]}"; do
        if dpkg -l | grep -q "^ii.*$pkg"; then
            echo "${NOTE} Removing package: $pkg" | tee -a "$LOG"
            sudo apt-get remove -y "$pkg" 2>&1 | grep -E "(Setting up|Removing)" | tee -a "$LOG" || true
        fi
    done
    
    # Remove binaries built from source
    echo "${INFO} Checking for binaries built from source..." | tee -a "$LOG"
    for binary in "${hyprland_binaries[@]}"; do
        if [ -e "$binary" ]; then
            echo "${NOTE} Removing binary: $binary" | tee -a "$LOG"
            sudo rm -f "$binary"
        fi
    done
    
    # Remove development files from /usr/local
    if [ -d "/usr/local/include/hyprland" ] || [ -d "/usr/local/lib/libhypr" ]; then
        echo "${INFO} Removing development files from /usr/local..." | tee -a "$LOG"
        sudo rm -rf /usr/local/include/hyprland* 2>/dev/null || true
        sudo rm -rf /usr/local/lib/libhypr* 2>/dev/null || true
        sudo rm -rf /usr/local/lib/libaquamarine* 2>/dev/null || true
        sudo rm -rf /usr/local/lib/libypr* 2>/dev/null || true
        sudo ldconfig 2>/dev/null || true
    fi
    
    echo "${OK} Cleanup completed" | tee -a "$LOG"
}


# Welcome / proceed (TTY or whiptail)
if [ "$TTY_MODE" -eq 1 ]; then
    echo "========================================"
    echo "KooL Debian-Hyprland Trixie+ Install Script"
    echo "========================================"
    echo "ATTENTION: Run a full system update and reboot first (recommended)."
    echo "NOTE: On VMs, enable 3D acceleration or Hyprland may not start."
    echo
    echo "Build method: FROM SOURCE"
    echo "IMPORTANT: Ensure deb-src is enabled in /etc/apt/sources.list."
    read -r -p "Proceed with installation? [y/N]: " _ans
    case "${_ans,,}" in
      y|yes) : ;;
      *) echo "${NOTE} You chose not to continue. Exiting..." | tee -a "$LOG"; exit 1 ;;
    esac
else
    # Welcome message using whiptail (for displaying information)
    whiptail --title "KooL Debian-Hyprland Trixie+ (2025) Install Script" \
        --msgbox "Welcome to KooL Debian-Hyprland Trixie+  (2025) Install Script!!!\n\n\
ATTENTION: Run a full system update and Reboot first !!! (Highly Recommended)\n\n\
NOTE: If you are installing on a VM, ensure to enable 3D acceleration otherwise Hyprland may NOT start!" \
        15 80
    proceed_msg="Build method: FROM SOURCE\n\nVERY IMPORTANT!!!\nYou must be able to install from source by uncommenting deb-src on /etc/apt/sources.list else script may fail.\n\nShall we proceed?"
    if ! whiptail --title "Proceed with Installation?" --yesno "$proceed_msg" 15 60; then
        echo -e "\n"
        echo "❌ ${INFO} You 🫵 chose ${YELLOW}NOT${RESET} to proceed. ${YELLOW}Exiting...${RESET}" | tee -a "$LOG"
        echo -e "\n"
        exit 1
    fi
fi

echo "👌 ${OK} 🇵🇭 ${MAGENTA}KooL..${RESET} ${SKY_BLUE}lets continue with the installation...${RESET}" | tee -a "$LOG"

sleep 1
printf "\n%.0s" {1..1}

# install pciutils if detected not installed. Necessary for detecting GPU
if ! dpkg -l | grep -w pciutils >/dev/null; then
    echo "pciutils is not installed. Installing..." | tee -a "$LOG"
    sudo apt install -y pciutils
    printf "\n%.0s" {1..1}
fi

# Path to the install-scripts directory
script_directory=install-scripts

# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            # Pass flags via env so sub-scripts can react without CLI churn
            if [ "${HYPR_BUILD_TRIXIE:-0}" = "1" ]; then
                env HYPR_BUILD_TRIXIE=1 HYPR_FORCE_REINSTALL=${FORCE_REINSTALL:-0} "$script_path" --build-trixie
            else
                env HYPR_BUILD_TRIXIE=0 HYPR_FORCE_REINSTALL=${FORCE_REINSTALL:-0} "$script_path"
            fi
        else
            echo "Failed to make script '$script' executable." | tee -a "$LOG"
        fi
    else
        echo "Script '$script' not found in '$script_directory'." | tee -a "$LOG"
    fi
}

# Load centralized Hyprland stack tags if present and export for child scripts
if [ -f "./hypr-tags.env" ]; then
    # shellcheck disable=SC1091
    source "./hypr-tags.env"
    # If core tags are set to auto/latest, refresh to resolve concrete versions
    if [ "${HYPRUTILS_TAG:-}" = "auto" ] || [ "${HYPRUTILS_TAG:-}" = "latest" ] || [ -z "${HYPRUTILS_TAG:-}" ] ||
        [ "${HYPRLANG_TAG:-}" = "auto" ] || [ "${HYPRLANG_TAG:-}" = "latest" ] || [ -z "${HYPRLANG_TAG:-}" ]; then
        if [ -f ./refresh-hypr-tags.sh ]; then
            chmod +x ./refresh-hypr-tags.sh || true
            ./refresh-hypr-tags.sh
            # reload after refresh
            # shellcheck disable=SC1091
            source "./hypr-tags.env"
        fi
    fi
    export HYPRLAND_TAG AQUAMARINE_TAG HYPRUTILS_TAG HYPRLANG_TAG HYPRGRAPHICS_TAG HYPRWAYLAND_SCANNER_TAG HYPRLAND_PROTOCOLS_TAG HYPRLAND_QT_SUPPORT_TAG HYPRLAND_QTUTILS_TAG HYPRWIRE_TAG WAYLAND_PROTOCOLS_TAG
fi

#################
## Default values for the options (will be overwritten by preset file if available)
gtk_themes="OFF"
bluetooth="OFF"
thunar="OFF"
ags="OFF"
quickshell="OFF"
sddm="OFF"
sddm_theme="OFF"
xdph="OFF"
zsh="OFF"
pokemon="OFF"
rog="OFF"
dots="OFF"
input_group="OFF"
nvidia="OFF"

# Function to load preset file
load_preset() {
    if [ -f "$1" ]; then
        echo "✅ Loading preset: $1"
        source "$1"
    else
        echo "⚠️ Preset file not found: $1. Using default values."
    fi
}

# Check if --preset argument is passed (order-independent)
if [ -n "${PRESET_FILE:-}" ]; then
    load_preset "$PRESET_FILE"
fi

# List of services to check for active login managers
services=("gdm.service" "gdm3.service" "lightdm.service" "lxdm.service")

# Function to check if any login services are active
check_services_running() {
    active_services=() # Array to store active services
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            active_services+=("$svc")
        fi
    done

    if [ ${#active_services[@]} -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

if check_services_running; then
    active_list=$(printf "%s\n" "${active_services[@]}")

    if [ "$TTY_MODE" -eq 1 ]; then
        echo "${WARN} Active non-SDDM login manager(s) detected:" 
        echo "$active_list"
        echo "NOTE: SDDM and SDDM theme options will be hidden."
    else
        # Display the active login manager(s) in the whiptail message box
        whiptail --title "Active non-SDDM login manager(s) detected" \
            --msgbox "The following login manager(s) are active:\n\n$active_list\n\nIf you want to install SDDM and SDDM theme, stop and disable first the active services above, and reboot before running this script\nRefer to README on switching to SDDM if you really want SDDM\n\nNOTE: Your option to install SDDM and SDDM theme has now been removed\n\n- Ja " 28 80
    fi
fi

# Check if NVIDIA GPU is detected
nvidia_detected=false
if lspci | grep -i "nvidia" &>/dev/null; then
    nvidia_detected=true
    whiptail --title "NVIDIA GPU Detected" --msgbox "NVIDIA GPU detected in your system.\n\nNOTE: The script will install nvidia-dkms, nvidia-utils, and nvidia-settings if you choose to configure." 12 60
fi

# Initialize the options array for whiptail checklist
options_command=(
    whiptail --title "Select Options" --checklist "Choose options to install or configure\nNOTE: 'SPACEBAR' to select & 'TAB' key to change selection" 28 85 20
)

# Add NVIDIA options if detected
if [ "$nvidia_detected" == "true" ]; then
    options_command+=(
        "nvidia" "Do you want script to configure NVIDIA GPU?" "OFF"
    )
fi

# Check if user is already in the 'input' group
input_group_detected=false
if ! groups "$(whoami)" | grep -q '\binput\b'; then
    input_group_detected=true
    whiptail --title "Input Group" --msgbox "You are not currently in the input group.\n\nAdding you to the input group might be necessary for the Waybar keyboard-state functionality." 12 60
fi

# Add 'input_group' option if user is not in input group
if [ "$input_group_detected" == "true" ]; then
    options_command+=(
        "input_group" "Add your USER to input group for some waybar functionality?" "OFF"
    )
fi

# Conditionally add SDDM and SDDM theme options if no active login manager is found
if ! check_services_running; then
    options_command+=(
        "sddm" "Install & configure SDDM login manager?" "OFF"
        "sddm_theme" "Download & Install Additional SDDM theme?" "OFF"
    )
fi

# Add the remaining static options (XDPH now installed by default; removed from menu)
options_command+=(
    "gtk_themes" "Install GTK themes (required for Dark/Light function)" "OFF"
    "bluetooth" "Do you want script to configure Bluetooth?" "OFF"
    "thunar" "Do you want Thunar file manager to be installed?" "OFF"
    "ags" "Install AGS v1 for Desktop-Like Overview" "OFF"
    "quickshell" "Install Quickshell (QtQuick-based shell toolkit)?" "OFF"
    "zsh" "Install zsh shell with Oh-My-Zsh?" "OFF"
    "pokemon" "Add Pokemon color scripts to your terminal?" "OFF"
    "rog" "Are you installing on Asus ROG laptops?" "OFF"
    "dots" "Download and install pre-configured KooL Hyprland dotfiles?" "OFF"
)

# Capture the selected options before the while loop starts
if [ "$TTY_MODE" -eq 1 ]; then
    # Build a simple list of available keys
    available_opts=()
    if [ "$nvidia_detected" == "true" ]; then available_opts+=(nvidia); fi
    if [ "$input_group_detected" == "true" ]; then available_opts+=(input_group); fi
    if ! check_services_running; then available_opts+=(sddm sddm_theme); fi
    available_opts+=(gtk_themes bluetooth thunar ags quickshell zsh pokemon rog dots)

    while true; do
        echo "Available options (space-separated):"
        printf '  %s\n' "${available_opts[@]}"
        read -r -p "Enter options to install/configure: " selected_options
        selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')
        if [ -z "$selected_options" ]; then
            echo "${WARN} No options selected. Please enter at least one."
            continue
        fi
        IFS=' ' read -r -a options <<<"$selected_options"
        echo "You selected: ${options[*]}"
        read -r -p "Proceed with these choices? [y/N]: " yn
        case "${yn,,}" in
          y|yes) break ;;
          *) echo "Returning to selection..." ;;
        esac
    done
else
    while true; do
        selected_options=$("${options_command[@]}" 3>&1 1>&2 2>&3)
        if [ $? -ne 0 ]; then
            echo -e "\n"
            echo "❌ ${INFO} You 🫵 cancelled the selection. ${YELLOW}Goodbye!${RESET}" | tee -a "$LOG"
            exit 0
        fi
        if [ -z "$selected_options" ]; then
            whiptail --title "Warning" --msgbox "No options were selected. Please select at least one option." 10 60
            continue
        fi
        selected_options=$(echo "$selected_options" | tr -d '"' | tr -s ' ')
        IFS=' ' read -r -a options <<<"$selected_options"
        dots_selected="OFF"
        for option in "${options[@]}"; do
            if [[ "$option" == "dots" ]]; then
                dots_selected="ON"; break
            fi
        done
        if [[ "$dots_selected" == "OFF" ]]; then
            if ! whiptail --title "KooL Hyprland Dot Files" --yesno \
                "You have not selected to install the pre-configured KooL Hyprland dotfiles.\n\nKindly NOTE that if you proceed without Dots, Hyprland will start with default vanilla Hyprland configuration and I won't be able to give you support.\n\nWould you like to continue install without KooL Hyprland Dots or return to choices/options?" \
                --yes-button "Continue" --no-button "Return" 15 90; then
                echo "🔙 Returning to options..." | tee -a "$LOG"
                continue
            else
                echo "${INFO} ⚠️ Continuing WITHOUT the dotfiles installation..." | tee -a "$LOG"
                printf "\n%.0s" {1..1}
            fi
        fi
        confirm_message="You have selected the following options:\n\n"
        for option in "${options[@]}"; do
            confirm_message+=" - $option\n"
        done
        confirm_message+="\nAre you happy with these choices?"
        if ! whiptail --title "Confirm Your Choices" --yesno "$(printf "%s" "$confirm_message")" 25 80; then
            echo -e "\n"
            echo "❌ ${SKY_BLUE}You're not 🫵 happy${RESET}. ${YELLOW}Returning to options...${RESET}" | tee -a "$LOG"
            continue
        fi
        echo "👌 ${OK} You confirmed your choices. Proceeding with ${SKY_BLUE}KooL 🇵🇭 Hyprland Installation...${RESET}" | tee -a "$LOG"
        break
    done
fi

printf "\n%.0s" {1..1}

# Verify APT sources before updating (deb-src + non-free components)
echo "${INFO} Verifying APT sources (deb-src, non-free, non-free-firmware)..." | tee -a "$LOG"
verify_and_offer_fix_apt_sources

echo "${INFO} Running a ${SKY_BLUE}full system update...${RESET}" | tee -a "$LOG"
sudo apt update

sleep 1
# execute pre clean up
execute_script "02-pre-cleanup.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary dependencies...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "00-dependencies.sh"

echo "${INFO} Installing ${SKY_BLUE}necessary fonts...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "fonts.sh"

# Build from source (only method)
# Optional: refresh tags before building the Hyprland stack
# Set FETCH_LATEST=1 to opt-in (default is no-refresh to honor pinned tags)
if [ "${FETCH_LATEST:-0}" = "1" ] && [ -f ./refresh-hypr-tags.sh ]; then
    chmod +x ./refresh-hypr-tags.sh || true
    ./refresh-hypr-tags.sh
fi

echo "${INFO} Installing ${SKY_BLUE}KooL Hyprland packages from source...${RESET}" | tee -a "$LOG"
sleep 1
execute_script "01-hypr-pkgs.sh"
sleep 1
execute_script "hyprutils.sh"
sleep 1
execute_script "hyprlang.sh"
sleep 1
execute_script "hyprcursor.sh"
sleep 1
execute_script "hyprwayland-scanner.sh"
sleep 1
execute_script "hyprgraphics.sh"
sleep 1
execute_script "aquamarine.sh"
sleep 1
execute_script "hyprland-qt-support.sh"
sleep 1
execute_script "hyprtoolkit.sh"
sleep 1
execute_script "hyprland-guiutils.sh"
sleep 1
execute_script "hyprland-protocols.sh"
sleep 1
# Ensure wayland-protocols (from source) is installed to satisfy Hyprland's >= 1.45 requirement
execute_script "wayland-protocols-src.sh"
sleep 1
execute_script "xkbcommon.sh"
sleep 1
# Build hyprwire before Hyprland (required by Hyprland >= 0.53)
execute_script "hyprwire.sh"
sleep 1
execute_script "hyprland.sh"
sleep 1
execute_script "hyprpolkitagent.sh"
sleep 1
execute_script "wallust.sh"
sleep 1
execute_script "swww.sh"
sleep 1
execute_script "rofi-wayland.sh"
sleep 1
execute_script "hyprlock.sh"
sleep 1
execute_script "hypridle.sh"

# Install XDG-Desktop-Portal-Hyprland by default (removed from menu)
execute_script "xdph.sh"

# Ensure /usr/local/lib is in the dynamic linker search path.
# Many Hypr* components install shared libraries into /usr/local/lib; without this,
# tools like hyprctl can fail to load (e.g. missing libhyprwire.so.*).
if ! sudo grep -qxF "/usr/local/lib" /etc/ld.so.conf.d/usr-local.conf 2>/dev/null; then
    echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf.d/usr-local.conf >/dev/null
fi
sudo ldconfig 2>/dev/null || true

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
    quickshell)
        echo "${INFO} Installing ${SKY_BLUE}Quickshell${RESET} (QtQuick-based shell toolkit)..." | tee -a "$LOG"
        execute_script "quickshell.sh"
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
files_to_delete=("JetBrainsMono.tar.xz" "VictorMonoAll.zip" "FantasqueSansMono.zip")
for file in "${files_to_delete[@]}"; do
    if [ -e "$file" ]; then
        echo "$file found. Deleting..." | tee -a "$LOG"
        rm "$file"
        echo "$file deleted successfully." | tee -a "$LOG"
    fi
done

clear

# copy fastfetch config if debian is not present
if [ ! -f "$HOME/.config/fastfetch/debian.png" ]; then
    cp -r assets/fastfetch "$HOME/.config/"
fi

printf "\n%.0s" {1..2}
# final check essential packages if it is installed
execute_script "03-Final-Check.sh"

printf "\n%.0s" {1..1}

# Check if either hyprland or Hyprland files exist in /usr/local/bin/
if [ -e /usr/local/bin/hyprland ] || [ -f /usr/local/bin/Hyprland ]; then
    printf "\n ${OK} 👌 Hyprland is installed. However, some essential packages may not be installed. Please see above!"
    printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
    sleep 2
    printf "\n%.0s" {1..2}

    printf "${SKY_BLUE}Thank you${RESET} 🫰 for using 🇵🇭 ${MAGENTA}KooL's Hyprland Dots${RESET}. ${YELLOW}Enjoy and Have a good day!${RESET}"
    printf "\n%.0s" {1..2}

    printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} (IF SDDM is not installed) (note the capital H!).\n"
    printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

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
            # Check if NVIDIA GPU is present
            if lspci | grep -i "nvidia" &>/dev/null; then
                echo "${INFO} HOWEVER ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..."
                printf "\n%.0s" {1..1}
            fi
            break
        else
            echo "${WARN} Invalid response. Please answer with 'y' or 'n'."
        fi
    done
else
    # Print error message if neither package is installed
    printf "\n${WARN} Hyprland is NOT installed. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory..."
    printf "\n%.0s" {1..3}
    exit 1
fi

printf "\n%.0s" {1..2}
