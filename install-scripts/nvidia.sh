#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Nvidia - Check Readme for more details for the drivers #
# UBUNTU USERS, FOLLOW README!

nvidia_pkg=(
    nvidia-driver
    firmware-misc-nonfree
    nvidia-kernel-dkms
    linux-headers-"$(uname -r)"
    libnvidia-egl-wayland1
    libva-wayland2
    libnvidia-egl-wayland1
    nvidia-vaapi-driver
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"
MLOG="install-$(date +%d-%H%M%S)_nvidia2.log"

if [[ $DRY -eq 1 ]]; then
    echo "Not creating /etc/apt/sources.list.d/sid.sources to fetch packages from Debian Sid (unstable)"
else
    ## adding the deb source for nvidia driver
    # Create a backup of the sources.list file
    if [[ -f /etc/apt/sources.list.d/sid.sources ]]; then
        verbose_log "Copying /etc/apt/sources.list.d/sid.sources to /etc/apt/sources.list.d/sid.sources.backup with sudo cp -a since /etc/apt/sources.list.d/sid.sources exists"
        sudo cp -a /etc/apt/sources.list.d/sid.sources /etc/apt/sources.list.d/sid.sources.backup 2>&1 | tee -a "$LOG"
    else
        verbose_log "/etc/apt/sources.list.d/sid.sources nonexistent, so not backing up with cp"
    fi

    ## UBUNTU - NVIDIA (comment this nine by adding # you don't need this!)
    # Add the comment and repository entry to sources.list
    echo "## for nvidia" | sudo tee -a /etc/apt/sources.list.d/sid.sources 2>&1 | tee -a "$LOG"
    cat "/etc/apt/sources.list.d/sid.sources" <<EOF
Types: deb deb-src
URIs: https://deb.debian.org/debian/
Suites: unstable
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
Architectures: amd64
EOF

    # Update the package list
    sudo apt update
fi

# Function to add a value to a configuration file if not present
add_to_file() {
    local config_file="$1"
    local value="$2"

    if ! sudo grep -q "$value" "$config_file"; then
        echo "Adding $value to $config_file"
        if [[ $DRY -eq 1 ]]; then
            echo "${NOTE} Not adding $value to $config_file"
        else
            sudo sh -c "echo '$value' >> '$config_file'"
        fi
    else
        echo "$value is already present in $config_file."
    fi
}

# Install additional Nvidia packages
printf "${YELLOW} Installing ${SKY_BLUE}Nvidia packages${RESET} ...\n"
for NVIDIA in "${nvidia_pkg[@]}"; do
    install_package "$NVIDIA" "$LOG"
done

# adding additional nvidia-stuff
printf "${YELLOW} adding ${SKY_BLUE}nvidia-stuff${RESET} to /etc/default/grub..."

# Additional options to add to GRUB_CMDLINE_LINUX
additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1"

# Check if additional options are already present in GRUB_CMDLINE_LINUX
if grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub; then
    echo "GRUB_CMDLINE_LINUX already contains the additional options"
else
    if [[ $DRY -eq 1 ]]; then
        echo "${NOTE} Not adding 'rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1' to GRUB_CMDLINE_LINUX in /etc/default/grub"
    else
        # Append the additional options to GRUB_CMDLINE_LINUX
        sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /" /etc/default/grub
        echo "Added the additional options to GRUB_CMDLINE_LINUX"
    fi
fi

if [[ $DRY -eq 1 ]]; then
    echo "${NOTE} Not updating GRUB configuration with sudo update-grub"
else
    # Update GRUB configuration
    sudo update-grub 2>&1 | tee -a "$LOG"
fi

# Define the configuration file and the line to add
config_file="/etc/modprobe.d/nvidia.conf"
line_to_add="""
    options nvidia-drm modeset=1 fbdev=1
    options nvidia NVreg_PreserveVideoMemoryAllocations=1
    """

# Check if the config file exists
if [ ! -e "$config_file" ]; then
    echo "Creating $config_file"
    if [[ $DRY -eq 1 ]]; then
        echo "${NOTE} Not creating $config_file with touch"
    else
        sudo touch "$config_file" 2>&1 | tee -a "$LOG"
    fi
fi

add_to_file "$config_file" "$line_to_add"

# Add NVIDIA modules to initramfs configuration
modules_to_add="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
modules_file="/etc/initramfs-tools/modules"

if [ -e "$modules_file" ]; then
    add_to_file "$modules_file" "$modules_to_add" 2>&1 | tee -a "$LOG"
    if [[ $DRY -eq 1 ]]; then
        echo "${NOTE} Not updating initramfs with sudo update-initramfs -uk all"
    else
        sudo update-initramfs -uk all 2>&1 | tee -a "$LOG"
    fi
else
    echo "Modules file ($modules_file) not found." 2>&1 | tee -a "$LOG"
fi

newlines 2
