# Hyprland Installation Method Guide

## Overview

The `install.sh` script has been updated to support **two installation methods** with automatic cleanup of existing installations:

1. **Build from Source** (original method - slower, ~1-2 hours)
2. **Install from Pre-built Packages** (new method - faster, ~5-10 minutes)

## Key Features

### 1. Package Source Configuration

Located at the top of `install.sh`:

```bash
DEB_PACKAGES_SOURCE="/mnt/nas/Projects/Jak/debian-pkg/build/debs"
```

**Modify this variable to:**
- Point to a local directory with .deb files
- Point to a network share (NAS/SMB/NFS)
- Leave empty (`""`) to always build from source

### 2. Automatic Build Method Selection

When you run `install.sh`:

```
1. Script checks if DEB_PACKAGES_SOURCE exists and contains .deb files
2. If found, prompts: "Install from pre-built packages or build from source?"
   - YES → Install from packages (5-10 minutes)
   - NO  → Build from source (1-2 hours)
3. If not found, defaults to building from source
```

### 3. Automatic Cleanup Before Package Installation

When installing from pre-built packages, the script **automatically removes** any existing Hyprland installations:

#### .deb Packages Removed
```
- hyprland
- hyprutils
- hyprgraphics
- hyprcursor
- hyprtoolkit
- hyprland-guiutils
- hyprwire
- aquamarine
- hypridle
- hyprlock
- hyprpolkitagent
- hyprpicker
- xdg-desktop-portal-hyprland
- hyprland-plugins
```

#### Binaries Removed
```
- /usr/local/bin/Hyprland
- /usr/local/bin/hyprland
- /usr/bin/Hyprland
- /usr/bin/hyprland
```

#### Development Files Removed
```
- /usr/local/include/hyprland*
- /usr/local/lib/libhypr*
- /usr/local/lib/libaquamarine*
- /usr/local/lib/libypr*
```

#### Cleanup Steps
1. Removes all installed .deb packages using `apt-get remove`
2. Deletes source-built binaries
3. Removes development files from /usr/local
4. Updates library cache with `ldconfig`
5. Updates package cache with `apt-get update`
6. Installs new packages from .deb files
7. Fixes any dependency issues with `apt-get install -f`

## Usage

### Basic Usage (Automatic Method Selection)

```bash
cd ~/Projects/Jak/Debian-Hyprland
./install.sh
```

The script will:
1. Detect available packages at `DEB_PACKAGES_SOURCE`
2. Ask which method you prefer
3. Execute the selected method with proper cleanup

### Using Pre-built Packages (Current Setup)

**Current package location:** `/mnt/nas/Projects/Jak/debian-pkg/build/debs`

```bash
./install.sh
# When prompted: Select YES to use pre-built packages
# Script will:
# 1. Remove any existing Hyprland installations
# 2. Install 59 .deb packages (~5-10 minutes)
# 3. Verify installations
```

### Using Custom Package Location

Edit `install.sh` to change the source:

```bash
# Edit this line in install.sh:
DEB_PACKAGES_SOURCE="/path/to/your/packages"

# Then run:
./install.sh
```

### Building from Source

Option 1: Edit script to disable packages
```bash
# In install.sh, change:
DEB_PACKAGES_SOURCE=""

# Then run:
./install.sh
```

Option 2: During installation
```bash
./install.sh
# When prompted: Select NO to build from source
```

## Installation Flow

```
START
  ↓
Check DEB_PACKAGES_SOURCE exists and has .deb files
  ↓
  ├─ YES → Prompt user for build method
  │         ├─ YES → Install from packages (selected method)
  │         │         ├─ Clean existing installations
  │         │         ├─ Remove .deb packages
  │         │         ├─ Remove source binaries
  │         │         ├─ Remove dev files
  │         │         ├─ Update package cache
  │         │         ├─ Install all .deb files
  │         │         ├─ Fix dependencies
  │         │         └─ Done
  │         │
  │         └─ NO → Build from source (selected method)
  │                  └─ Execute source build scripts
  │
  └─ NO → Build from source (default method)
           └─ Execute source build scripts
```

## Available Pre-built Packages

**Location:** `/mnt/nas/Projects/Jak/debian-pkg/build/debs`
**Total:** 59 .deb files

### Core Packages
- hyprland 0.52.2
- hyprutils 0.10.4
- hyprgraphics 0.4.0
- aquamarine 0.10.0
- hyprtoolkit 0.4.0

### Utilities & Tools
- hypridle 0.1.7
- hyprlock 0.9.2
- hyprpicker 0.4.5
- hyprpolkitagent 0.1.3
- hyprcursor 0.1.13

### Extensions
- hyprland-guiutils 0.1.0
- hyprland-qt-support 0.1.0
- hyprwire 0.2.1
- xdg-desktop-portal-hyprland 1.3.11
- hyprland-plugins 0.52.0 (9 plugins)

### Package Types
- Binary packages: 28
- Development (-dev): 7
- Debug symbols (-dbgsym): 24

## Cleanup Function Details

### Function: `clean_existing_hyprland()`

**Purpose:** Remove conflicting installations before installing from packages

**Operations:**
1. **Package Removal**
   - Uses `apt-get remove -y` for clean uninstallation
   - Removes only installed packages (checks with `dpkg -l`)

2. **Binary Removal**
   - Removes compiled binaries from /usr/bin and /usr/local/bin
   - Safely handles missing files

3. **Development File Removal**
   - Clears header files from /usr/local/include/
   - Clears library files from /usr/local/lib/
   - Updates library cache

**Logging:** All actions logged to Install-Logs directory

## Troubleshooting

### "No .deb files found" error

**Solution:**
```bash
# Check if directory exists:
ls -la /mnt/nas/Projects/Jak/debian-pkg/build/debs/

# Verify files are readable:
ls /mnt/nas/Projects/Jak/debian-pkg/build/debs/*.deb | wc -l

# If network share, verify mount:
mount | grep nas
```

### Package installation fails

**Solution:**
```bash
# Manually fix dependencies:
sudo apt-get install -f -y

# Check package status:
dpkg -l | grep hyprland
```

### Conflicts with source-built version

The cleanup function should handle this automatically. If issues persist:

```bash
# Manual cleanup:
sudo apt-get remove -y hyprland* hyprutils* hyprgraphics* aquamarine* hyprtoolkit*
sudo rm -rf /usr/local/include/hyprland* /usr/local/lib/libhypr*
sudo ldconfig
sudo apt-get update
```

## Environment Variables

### DEB_PACKAGES_SOURCE

- **Type:** Path (local or network)
- **Default:** `/mnt/nas/Projects/Jak/debian-pkg/build/debs`
- **Usage:** Specifies where pre-built .deb packages are located
- **Can be:** 
  - Local path: `/home/user/debs`
  - Network share: `//nas/share/debs`
  - Empty (to disable): `""`

## Performance Comparison

| Aspect | Source Build | Pre-built Packages |
|--------|--------------|-------------------|
| Time | 1-2 hours | 5-10 minutes |
| Complexity | High (compile, test) | Low (install only) |
| Disk Space | ~10-20GB | ~1-2GB |
| Build Tools | Required | Not needed |
| Customization | Full control | Fixed version |
| Network Dependency | GitHub API | Package location |

## Version Information

- **Script Updated:** 2025-12-13
- **Compatible with:** Debian Trixie / SiD
- **Hyprland Version:** 0.52.2
- **Build System:** dpkg-buildpackage
- **Pre-built Package Count:** 59 files

## Notes

- **Cleanup is automatic:** No manual intervention needed when switching from source to packages
- **Safe removal:** Only removes known Hyprland packages and binaries
- **Dependency fixing:** Automatic `apt-get install -f` handles missing dependencies
- **Logging:** All operations logged to Install-Logs/ directory
- **Network shares:** Works with NFS, SMB, or local paths

## Support

For issues:
1. Check Install-Logs/ directory for detailed error messages
2. Verify package location exists and is accessible
3. Ensure read permissions on .deb files
4. Run `apt-get update` manually if needed
5. Check system resources (disk space, RAM)
