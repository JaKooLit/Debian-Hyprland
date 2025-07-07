# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **KooL Debian-Hyprland** project - an automated installer for the Hyprland window manager on Debian Testing (Trixie) and SID (unstable). The project provides a comprehensive installation script that sets up Hyprland with a complete desktop environment, themes, and customizations.

**Important Context:**
- Hyprland is a **bleeding-edge** dynamic tiling Wayland compositor
- This installer addresses the fact that Debian/Ubuntu's packaged Hyprland versions are extremely outdated
- The project builds most components from source to ensure compatibility and latest features
- Hyprland requires C++26 standard support (gcc>=15 or clang>=19)

**Key Features:**
- Automated Hyprland installation with dependencies
- Pre-configured dotfiles and themes
- Support for NVIDIA GPUs
- Modular installation system
- Interactive user selection interface
- Comprehensive logging and error handling

## Architecture

### Core Components

**Main Scripts:**
- `install.sh` - Main installation orchestrator with whiptail UI
- `auto-install.sh` - One-line installer for remote execution
- `preset.sh` - Preset configuration file for automated installations
- `uninstall.sh` - Guided removal script

**Install Scripts Directory (`install-scripts/`):**
- `Global_functions.sh` - Shared utility functions library
- `00-dependencies.sh` - System dependencies and build tools
- `01-hypr-pkgs.sh` - Hyprland ecosystem packages
- `02-pre-cleanup.sh` - Pre-installation cleanup
- `03-Final-Check.sh` - Post-installation validation
- Component-specific scripts: `hyprland.sh`, `waybar.sh`, `rofi-wayland.sh`, etc.

### Script Architecture Pattern

All install scripts follow this standardized structure:

```bash
#!/bin/bash
# Package arrays definition
packages=( package1 package2 package3 )

# Navigate to parent directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR"

# Source shared functions
source Global_functions.sh

# Unique timestamped log file
LOG="Install-Logs/install-$(date +%d-%H%M%S)_component.log"

# Installation with progress tracking
for PKG in "${packages[@]}"; do
    install_package "$PKG" "$LOG"
done
```

## Common Development Tasks

### Running the Installation

**Standard Installation:**
```bash
chmod +x install.sh
./install.sh
```

**With Preset Configuration:**
```bash
./install.sh --preset preset.sh
```

**Auto-installation (remote):**
```bash
sh <(curl -L https://raw.githubusercontent.com/JaKooLit/Debian-Hyprland/main/auto-install.sh)
```

### Testing Individual Components

**Run specific install scripts:**
```bash
# Must be run from repository root, not inside install-scripts/
./install-scripts/component.sh
```

**Example component installations:**
```bash
./install-scripts/gtk_themes.sh     # Install GTK themes
./install-scripts/sddm.sh           # Install SDDM login manager
./install-scripts/fonts.sh          # Install fonts
./install-scripts/dotfiles.sh       # Install dotfiles
```

### Validation and Debugging

**Check installation logs:**
```bash
# Logs are created in Install-Logs/ directory
ls -la Install-Logs/
tail -f Install-Logs/install-$(date +%d-%H%M%S)_component.log
```

**Validate essential packages:**
```bash
./install-scripts/03-Final-Check.sh
```

**Test prerequisite checks:**
```bash
# Check if user can install from source
grep -E "^deb-src" /etc/apt/sources.list
```

## Key Functions (Global_functions.sh)

**Package Management:**
- `install_package "$PKG" "$LOG"` - Install APT package with progress bar
- `build_dep "$PKG"` - Install build dependencies
- `cargo_install "$PKG"` - Install Rust package via Cargo
- `re_install_package "$PKG"` - Force reinstall package
- `uninstall_package "$PKG"` - Remove package with validation

**Progress and Logging:**
- `show_progress $PID "$package_name"` - Animated progress indicator
- All functions log to timestamped files in `Install-Logs/`
- Color-coded output: OK, ERROR, NOTE, INFO, WARN

## Source Building Patterns

Many components are built from source. Common patterns:

**Rust/Cargo Projects:**
```bash
git clone --recursive -b $tag https://github.com/repo.git
cd repo
source "$HOME/.cargo/env"
cargo build --release
sudo cp target/release/binary /usr/bin/
```

**Meson/Ninja Projects:**
```bash
meson setup build
ninja -C build
sudo ninja -C build install
```

## System Requirements

**Operating System:**
- Debian Testing (Trixie) or SID (unstable)
- **NOT compatible with Debian Stable (Bookworm)**
- Rolling release distros (Fedora, OpenSUSE) likely work well
- Ubuntu/Pop!_OS may have major compatibility issues due to outdated packages

**Prerequisites:**
- Non-root user with sudo privileges
- Uncommented `deb-src` lines in `/etc/apt/sources.list`
- C++26 compiler support (gcc>=15 or clang>=19)
- For NVIDIA users: nouveau driver uninstalled (if using proprietary drivers)

**Hardware Support:**
- NVIDIA GPU support via `nvidia.sh` script (requires special configuration)
- ASUS ROG laptop support via `rog.sh` script
- Bluetooth configuration via `bluetooth.sh` script

**Hyprland Core Dependencies:**
- aquamarine
- hyprlang
- hyprcursor
- hyprutils
- hyprgraphics
- hyprwayland-scanner (build-only)

## Important Notes

**Installation Behavior:**
- Scripts check for existing packages before installation
- Logs are timestamped and stored in `Install-Logs/`
- Failed installations continue with warnings
- Source-built packages install to `/usr/local/bin/` or `/usr/bin/`

**Common Issues:**
- Scripts must be run from repository root directory
- SDDM installation requires stopping other login managers first
- Network issues during source builds (swww, hyprlock, etc.)
- NVIDIA configuration requires system reboot
- GDM may have compatibility issues with Hyprland
- VM installations require special graphics configuration (virgl, mesa)

**File Locations:**
- Install logs: `Install-Logs/`
- Configuration backups: Created automatically
- Dotfiles: Downloaded from separate repository branch
- Themes: Installed to `/usr/share/themes/`

## Customization

**Package Selection:**
- Edit `install-scripts/01-hypr-pkgs.sh` to modify package lists
- Use `preset.sh` for automated installations
- Individual component scripts can be run separately

**Preset Configuration:**
```bash
# Example preset.sh entries
gtk_themes="ON"
bluetooth="ON"
thunar="ON"
dots="ON"
nvidia="OFF"
```

## Uninstallation

**Guided Removal:**
```bash
chmod +x uninstall.sh
./uninstall.sh
```

The uninstall script provides:
- Interactive package selection
- Configuration directory removal
- Locally-built package cleanup
- System stability warnings

## Hyprland Ecosystem Context

**About Hyprland:**
- Dynamic tiling Wayland compositor written in C++
- Extremely bleeding-edge with rapid development
- Requires latest dependencies and compiler support
- Not meant to be a full Desktop Environment - users must configure their own ecosystem

**Why This Installer Exists:**
- Official Debian/Ubuntu packages are extremely outdated and unusable
- Building from source requires complex dependency management
- This project automates the entire stack compilation and configuration
- Provides a complete, working Hyprland setup with dotfiles and themes

**Related Projects:**
- [Hyprland-Dots](https://github.com/JaKooLit/Hyprland-Dots) - Centralized dotfiles repository
- [Ubuntu-Hyprland](https://github.com/JaKooLit/Ubuntu-Hyprland) - Ubuntu-specific installer
- [Wallpaper-Bank](https://github.com/JaKooLit/Wallpaper-Bank) - Wallpaper collection

**Support Resources:**
- [Hyprland Wiki](https://wiki.hyprland.org/) - Official documentation
- [FAQ](https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ) - Common questions
- [Keybinds](https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds) - Default shortcuts
- [Discord](https://discord.gg/kool-tech-world) - Community support