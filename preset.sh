#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #

# Define the options you want to preselect (either ON or OFF)
# IMPORTANT: answer should be inside ""

# Remember to use the --preset option when calling install.sh so this is executed, such as
#   ./install.sh --preset preset.sh

### Script will install nvidia-dkms nvidia-utils & nvidia-settings
###-Would you like script to Configure NVIDIA for you?
export nvidia="OFF"

###-Install GTK themes (required for Dark/Light function)?
export gtk_themes="ON"

###-Do you want to configure Bluetooth?
export bluetooth="ON"

###-Do you want to install Thunar file manager?
export thunar="ON"

### Adding user to the 'input' group might be necessary for waybar keyboard-state functionality
export input_group="ON"

### Desktop overview Demo Link in README
### Desktop overview Demo Link in README
### Install AGS (aylur's GTK shell) v1 for Desktop-Like Overview?"
export ags="ON"

###-Install & configure SDDM log-in Manager
export sddm="ON"
### install and download SDDM themes
export sddm_theme="ON"

###-Install XDG-DESKTOP-PORTAL-HYPRLAND? (For proper Screen Share ie OBS)
export xdph="ON"

### Shell extension. Bash alternative
###-Install zsh, oh-my-zsh
export zsh="ON"
### add Pokemon color scripts to terminal
export pokemon="ON"

### This will install ASUSCTL & SUPERGFXCTL
###-Installing on Asus ROG Laptops?
export rog="OFF"

###-Download and Add pre-configured Hyprland dotfiles?
export dots="ON"
