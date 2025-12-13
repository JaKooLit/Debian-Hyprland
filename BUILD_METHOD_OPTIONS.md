# Hyprland Installation Method Options

## Overview

The `install.sh` script has been updated to support **two installation methods**:

1. **Build from Source** (Original method)
2. **Install from Pre-built Packages** (New method - faster)

## Configuration

### Setting the Package Source Location

At the top of `install.sh`, you'll find this variable:

```bash
DEB_PACKAGES_SOURCE="/mnt/nas/Projects/Jak/debian-pkg/build/debs"
```

**To change the package location:**
- Modify `DEB_PACKAGES_SOURCE` to point to your pre-built .deb package directory
- Can be a local path or network share
- Leave empty to always build from source

### Current Configuration

**Current source location:** `/mnt/nas/Projects/Jak/debian-pkg/build/debs`

**Available packages:** 59 .deb files
- All Hyprland components (0.52.2)
- All dependencies (utilities, graphics, cursors, etc.)
- 9 Hyprland plugins
- Debug symbols and development files

## Installation Flow

### Automatic Method Selection

When you run `install.sh`:

1. **Environment Check**: Script checks if packages are available at `DEB_PACKAGES_SOURCE`
2. **User Prompt**: If packages found, you're asked to choose:
   - **YES** → Install from pre-built packages (faster, ~5-10 minutes)
   - **NO** → Build from source (slower, ~1-2 hours)

3. **Execution**: Script runs the selected method

### Build from Source Method

If you choose "from source" or no packages are available:
- Runs all the original install scripts
- Builds each component from GitHub source
- Takes significantly longer but gives latest upstream code

### Build from Packages Method

If you choose "pre-built packages":
1. Validates package directory exists and contains .deb files
2. Counts available packages
3. Installs all .deb files using `dpkg -i`
4. Fixes any missing dependencies with `apt-get install -f`
5. Completes much faster than source builds

## Usage Examples

### To use current pre-built packages (on test network):

```bash
cd ~/Projects/Jak/Debian-Hyprland
./install.sh
# When prompted, select YES to use pre-built packages
```

### To always build from source (ignore packages):

```bash
# Edit install.sh and change:
DEB_PACKAGES_SOURCE=""
# Then run:
./install.sh
```

### To use packages from a different location:

```bash
# Edit install.sh and change:
DEB_PACKAGES_SOURCE="/path/to/your/packages"
# Then run:
./install.sh
```

## Building Your Own Packages

To generate pre-built packages:

```bash
cd /mnt/nas/Projects/Jak/debian-pkg
./build_all_final.sh
```

This creates all 59 .deb packages in `build/debs/`

## Package Versions

All pre-built packages match upstream versions:

| Package | Version |
|---------|---------|
| hyprland | 0.52.2 |
| hyprutils | 0.10.4 |
| hyprgraphics | 0.4.0 |
| aquamarine | 0.10.0 |
| hyprtoolkit | 0.4.0 |
| (and 11 more) | (see VERSION_VERIFICATION.txt) |

## Benefits of Each Method

### Build from Source
- ✅ Ensures latest upstream code
- ✅ Custom compilation options possible
- ❌ Takes 1-2 hours
- ❌ Requires all build tools and deb-src enabled

### Build from Packages
- ✅ Fast installation (5-10 minutes)
- ✅ Pre-tested and validated builds
- ✅ No build tools required
- ✅ Works from network share
- ❌ Fixed versions (no custom compilation)

## Troubleshooting

### "No .deb files found" error

**Solution:**
1. Check `DEB_PACKAGES_SOURCE` path exists
2. Verify .deb files are in that location
3. Check file permissions
4. Run `ls $DEB_PACKAGES_SOURCE/*.deb` to verify

### Package installation fails

**Solution:**
```bash
# Manually fix dependencies:
sudo apt-get install -f -y

# Or reinstall specific package:
sudo dpkg -i /path/to/package.deb
sudo apt-get install -f -y
```

### Mixed dependency errors

**Solution:** Ensure all interdependent packages are installed together:
```bash
sudo dpkg -i $DEB_PACKAGES_SOURCE/*.deb
sudo apt-get install -f -y
```

## Network Share Access

If packages are on a NAS/network share:

```bash
# Mount the share (if not already mounted):
sudo mount -t nfs nas:/path/to/share /mnt/nas

# Or modify DEB_PACKAGES_SOURCE to your network path:
DEB_PACKAGES_SOURCE="//nas/Projects/Jak/debian-pkg/build/debs"
```

## Version Information

- **Install script updated:** 2025-12-13
- **Package build system:** Debian dpkg-buildpackage
- **Supported distributions:** Debian Trixie / SiD
- **Pre-built packages location:** `/mnt/nas/Projects/Jak/debian-pkg/build/debs`
