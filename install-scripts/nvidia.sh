#!/bin/bash

nvidia_pkg=(
  nvidia-driver
  firmware-misc-nonfree
  nvidia-kernel-dkms
  linux-headers-$(uname -r)
  libva-wayland2
  nvidia-vaapi-driver
)

# for ubuntu-nvidia owners! just delete #
# sudo ubuntu-drivers install

############## WARNING DO NOT EDIT BEYOND THIS LINE if you dont know what you are doing! ######################################
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 166)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
ORANGE=$(tput setaf 166)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S)_nvidia.log"

set -e

## adding the deb source for nvidia driver
# Create a backup of the sources.list file
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup 2>&1 | tee -a "$LOG"

# Add the comment and repository entry to sources.list
echo "## for nvidia" | sudo tee -a /etc/apt/sources.list 2>&1 | tee -a "$LOG"
echo "deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list 2>&1 | tee -a "$LOG"

# Update the package list
sudo apt update

# Function for installing packages
install_package() {
  # Checking if package is already installed
  if sudo dpkg -l | grep -q "^ii  $1 " ; then
    echo -e "${OK} $1 is already installed. Skipping..."
  else
    # Package not installed
    echo -e "${NOTE} Installing $1 ..."
    sudo apt-get install -y "$1" 2>&1 | tee -a "$LOG"
    # Making sure the package is installed
    if sudo dpkg -l | grep -q "^ii  $1 " ; then
      echo -e "\e[1A\e[K${OK} $1 was installed."
    else
      # Something is missing, exiting to review the log
      echo -e "\e[1A\e[K${ERROR} $1 failed to install :( , please check the install.log. You may need to install manually! Sorry, I have tried :("
      exit 1
    fi
  fi
}

# Function to add a value to a configuration file if not present
add_to_file() {
    local config_file="$1"
    local value="$2"
    
    if ! sudo grep -q "$value" "$config_file"; then
        echo "Adding $value to $config_file"
        sudo sh -c "echo '$value' >> '$config_file'"
    else
        echo "$value is already present in $config_file."
    fi
}

# Clone, build, and install nvidia-Hyprland using Cmake
printf "${NOTE} Installing nvidia-Hyprland...\n"
if git clone --recursive https://github.com/hyprwm/Hyprland 2>&1 | tee -a "$LOG"; then
  cd Hyprland || exit 1
  # additional for hyprland-nvidia
  sed 's/glFlush();/glFinish();/g' -i subprojects/wlroots/render/gles2/renderer.c
  if sudo make install 2>&1 | tee -a "$LOG"; then
    printf "${OK} Nvidia-Hyprland installed successfully.\n"
    # Return to the previous directory
    cd ..
  else
    echo -e "${ERROR} Installation failed for Nvidia-Hyprland." 2>&1 | tee -a "$LOG"
  fi
else
  echo -e "${ERROR} Download failed for Nvidia-Hyprland." 2>&1 | tee -a "$LOG"
fi

# Install additional Nvidia packages
printf "${YELLOW} Installing Nvidia packages...\n"
  for NVIDIA in "${nvidia_pkg[@]}"; do
    install_package "$NVIDIA" 2>&1 | tee -a "$LOG"
  done

# Preparing exec.conf to enable env = WLR_NO_HARDWARE_CURSORS,1 so it will be ready once config files copied
sed -i '21s/#//' config/hypr/configs/ENVariables.conf

printf "${YELLOW} nvidia-stuff to /etc/default/grub..."

  # Additional options to add to GRUB_CMDLINE_LINUX
  additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1"

  # Check if additional options are already present in GRUB_CMDLINE_LINUX
  if grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub; then
    echo "GRUB_CMDLINE_LINUX already contains the additional options"
  else
    # Append the additional options to GRUB_CMDLINE_LINUX
    sudo sed -i "s/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /" /etc/default/grub
    echo "Added the additional options to GRUB_CMDLINE_LINUX"
  fi

  # Update GRUB configuration
  sudo update-grub 2>&1 | tee -a "$LOG"
    
  # Define the configuration file and the line to add
    config_file="/etc/modprobe.d/nvidia.conf"
    line_to_add="options nvidia-drm modeset=1"

    # Check if the config file exists
    if [ ! -e "$config_file" ]; then
        echo "Creating $config_file"
        sudo touch "$config_file" 2>&1 | tee -a "$LOG"
    fi

    add_to_file "$config_file" "$line_to_add"

   # Add NVIDIA modules to initramfs configuration
   modules_to_add="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
   modules_file="/etc/initramfs-tools/modules"

   if [ -e "$modules_file" ]; then
    add_to_file "$modules_file" "$modules_to_add" 2>&1 | tee -a "$LOG"
    sudo update-initramfs -u 2>&1 | tee -a "$LOG"
   else
    echo "Modules file ($modules_file) not found." 2>&1 | tee -a "$LOG"
   fi

clear
