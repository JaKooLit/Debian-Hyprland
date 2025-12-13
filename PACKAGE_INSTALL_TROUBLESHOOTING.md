# Package Installation Troubleshooting Guide

## Recent Update (2025-12-13)

The `install.sh` script has been updated to:
- **Skip plugins by default** (optional, can install manually)
- **Skip debug symbols by default** (optional, can install manually)
- **Focus on core packages only** for initial installation
- **Improve dependency resolution** with `apt-get install -f`

## Common Dependency Issues

### Issue: Missing libhyprlang2

**Error:**
```
hypridle depends on libhyprlang2 (>= 0.6.4); however:
Package libhyprlang2 is not installed.
```

**Cause:** libhyprlang is not included in the current pre-built packages. It needs to be built or installed from Debian repositories.

**Solution:**
```bash
# Option 1: Install from Debian repositories
sudo apt-get install libhyprlang2

# Option 2: Build from source (fallback to source method in install.sh)
```

### Issue: Missing libaquamarine8

**Error:**
```
hyprland depends on libaquamarine8 (>= 0.9.5); however:
Package libaquamarine8 is not installed.
```

**Cause:** Pre-built packages have libaquamarine9, not libaquamarine8. Version mismatch.

**Solution:**
```bash
# Check what's installed:
dpkg -l | grep aquamarine

# If you have libaquamarine9, it should work with newer hyprland
# If not, install aquamarine from packages:
sudo dpkg -i /mnt/nas/Projects/Jak/debian-pkg/build/debs/libaquamarine*.deb
```

### Issue: libstdc++6 version too old

**Error:**
```
hyprland depends on libstdc++6 (>= 15); however:
Version of libstdc++6:amd64 on system is 14.2.0-19.
```

**Cause:** System C++ standard library is older than required.

**Solution:**
```bash
# Update your system (highest priority):
sudo apt-get update
sudo apt-get upgrade

# Or install g++ 15:
sudo apt-get install g++-15
```

### Issue: libxkbcommon0 version too old

**Error:**
```
hyprland depends on libxkbcommon0 (>= 1.12.3); however:
Version of libxkbcommon0:amd64 on system is 1.7.0-2.
```

**Cause:** System xkbcommon library is older than required.

**Solution:**
```bash
# Update system packages:
sudo apt-get update
sudo apt-get upgrade libxkbcommon0

# Or build from source:
sudo apt-get build-dep libxkbcommon
```

## Installation Workflow (Updated)

### Step 1: Install Core Packages

```bash
cd ~/Projects/Jak/Debian-Hyprland
./install.sh
# Select YES to use pre-built packages
# Script will skip plugins and debug symbols automatically
```

**What gets installed:**
- Core libraries (hyprutils, hyprgraphics, hyprcursor, etc.)
- Main compositor (hyprland)
- Essential utilities (hypridle, hyprlock, etc.)
- Development files (-dev packages)

**What is skipped (can install manually later):**
- Hyprland plugins (9 optional plugins)
- Debug symbols (-dbgsym packages)

### Step 2: Fix Missing Dependencies

If you encounter missing dependencies:

```bash
# Install missing system dependencies:
sudo apt-get install -f -y

# This will attempt to resolve any broken dependencies from Debian repos
```

### Step 3: Install Optional Components

**Install plugins (if desired):**
```bash
sudo dpkg -i /mnt/nas/Projects/Jak/debian-pkg/build/debs/hyprland-plugin-*.deb
```

**Install debug symbols (if desired):**
```bash
sudo dpkg -i /mnt/nas/Projects/Jak/debian-pkg/build/debs/*-dbgsym*.deb
```

## Dependency Resolution Strategy

The updated script uses a staged approach:

1. **Install core packages** (libraries and binaries)
2. **Run `apt-get install -f`** to resolve from Debian repos
3. **Skip optional components** (plugins, debug)
4. **Provide manual install commands** for optional packages

## System Requirements

For successful installation, ensure:

| Component | Minimum | Recommended |
|-----------|---------|------------|
| libstdc++6 | 14.2.0 | 15.x |
| libxkbcommon0 | 1.7.0 | 1.12.3+ |
| Debian Release | Trixie | Trixie or newer |

## Upgrading System Libraries

If you have dependency version issues:

```bash
# Full system upgrade (safest approach)
sudo apt-get update
sudo apt-get upgrade

# Or targeted package upgrades
sudo apt-get install --only-upgrade libstdc++6
sudo apt-get install --only-upgrade libxkbcommon0
```

## Manual Installation Without Script

If the script fails, install packages manually:

```bash
cd /mnt/nas/Projects/Jak/debian-pkg/build/debs

# Install only core .deb files (not plugins or debug):
for deb in *.deb; do
    if [[ "$deb" != *"-dbgsym"* ]] && [[ "$deb" != "hyprland-plugin"* ]]; then
        sudo dpkg -i "$deb"
    fi
done

# Fix dependencies:
sudo apt-get install -f -y
```

## Known Issues

### Issue: Plugins require hyprland to be installed first
**Status:** Fixed in updated script (plugins skipped)
**Solution:** Install core packages first, then manually install plugins

### Issue: Debug symbols require main package
**Status:** Fixed in updated script (dbgsym skipped)
**Solution:** Install main packages first, then manually install -dbgsym

### Issue: Some libraries missing from pre-built
**Status:** Partially fixed with `apt-get install -f`
**Solution:** Keep system updated, use fallback to source build if needed

## Fallback to Source Build

If package installation fails completely:

```bash
cd ~/Projects/Jak/Debian-Hyprland
./install.sh
# When prompted: Select NO to build from source instead
# Takes 1-2 hours but builds everything from scratch
```

## Getting Help

1. **Check Install-Logs directory:**
   ```bash
   cat Install-Logs/01-Hyprland-Install-Scripts-*.log
   ```

2. **Check package status:**
   ```bash
   dpkg -l | grep hyprland
   apt-cache policy hyprland
   ```

3. **Check system libraries:**
   ```bash
   ldd /usr/bin/Hyprland
   dpkg -l | grep libstdc++6
   dpkg -l | grep libxkbcommon0
   ```

## Summary

**Core Changes (2025-12-13):**
- ✅ Skip plugins by default (reduce dependency issues)
- ✅ Skip debug symbols by default (faster installation)
- ✅ Auto-fix missing Debian dependencies with `apt-get install -f`
- ✅ Provide manual commands for optional packages
- ✅ Better error handling and logging

**Installation Time:**
- Core packages: 5-10 minutes
- With plugins: +5 minutes
- With debug symbols: +10 minutes

**Next Steps After Install:**
```bash
# Verify installation:
hyprland --version
Hyprland --help

# Install plugins (optional):
sudo dpkg -i /mnt/nas/Projects/Jak/debian-pkg/build/debs/hyprland-plugin-*.deb

# Install debug symbols (optional):
sudo dpkg -i /mnt/nas/Projects/Jak/debian-pkg/build/debs/*-dbgsym*.deb

# Reboot to ensure all changes take effect:
sudo reboot
```
