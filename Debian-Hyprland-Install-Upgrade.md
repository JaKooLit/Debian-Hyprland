# Debian-Hyprland Install & Upgrade Guide

This guide covers the enhanced installation and upgrade workflows for KooL's Debian-Hyprland project, including new automation features, centralized version management, and dry-run capabilities.

## Table of Contents

1. [Overview](#overview)
2. [New Features](#new-features)
3. [Central Version Management](#central-version-management)
4. [Installation Methods](#installation-methods)
5. [Upgrade Workflows](#upgrade-workflows)
6. [Dry-Run Testing](#dry-run-testing)
7. [Log Management](#log-management)
8. [Advanced Usage](#advanced-usage)
9. [Troubleshooting](#troubleshooting)

## Overview

The Debian-Hyprland project now includes enhanced automation and management tools while maintaining backward compatibility with the original install.sh script. The key additions are:

- **Centralized version management** via `hypr-tags.env`
- **Automated dependency ordering** for Hyprland 0.51.x requirements
- **Dry-run compilation testing** without system modifications
- **Selective component updates** via `update-hyprland.sh`
- **GitHub latest tag fetching** for automatic version discovery

## New Features

### Enhanced install.sh
The original install.sh script now includes:

- **Tag consistency**: Reads `hypr-tags.env` and exports version variables to all modules
- **Automatic wayland-protocols**: Installs wayland-protocols from source (≥1.45) before Hyprland
- **Robust dependency ordering**: Ensures prerequisites are built in the correct sequence

### New Scripts

#### update-hyprland.sh
A focused tool for managing and building just the Hyprland stack:
```bash
chmod +x ./update-hyprland.sh
./update-hyprland.sh --help  # View all options
```

#### dry-run-build.sh
A testing tool that compiles components without installing:
```bash
chmod +x ./dry-run-build.sh
./dry-run-build.sh --help  # View all options
```

#### wayland-protocols-src.sh
A new module that builds wayland-protocols from source to satisfy Hyprland 0.51.x requirements.

## Central Version Management

### hypr-tags.env
This file contains version tags for all Hyprland components:

```bash
# Current versions (example)
HYPRLAND_TAG=v0.51.1
AQUAMARINE_TAG=v0.9.3
HYPRUTILS_TAG=v0.8.2
HYPRLANG_TAG=v0.6.4
HYPRGRAPHICS_TAG=v0.1.5
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.6.4
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.4
WAYLAND_PROTOCOLS_TAG=1.45
```

### Version Override Priority
1. Environment variables (exported)
2. hypr-tags.env file values
3. Default hardcoded values in each module

## Installation Methods

### Method 1: Original Full Installation
```bash
# Standard installation with all components
chmod +x install.sh
./install.sh
```

This method now automatically:
- Loads versions from `hypr-tags.env`
- Installs wayland-protocols from source before Hyprland
- Maintains proper dependency ordering

### Method 2: Hyprland Stack Only
```bash
# Install only Hyprland and essential components
./update-hyprland.sh --install
```

### Method 3: Fresh Installation with Latest Versions
```bash
# Fetch latest GitHub releases and install
./update-hyprland.sh --fetch-latest --install
```

### Method 4: Preset-Based Installation
```bash
# Use preset file for automated choices
./install.sh --preset ./preset.sh
```

## Upgrade Workflows

### Upgrading to Latest Hyprland Release

#### Option A: Automatic Discovery
```bash
# Fetch latest tags and install
./update-hyprland.sh --fetch-latest --install
```

#### Option B: Specific Version
```bash
# Set specific Hyprland version
./update-hyprland.sh --set HYPRLAND=v0.51.1 --install
```

#### Option C: Test Before Installing
```bash
# Test compilation first, then install if successful
./update-hyprland.sh --fetch-latest --dry-run
# If successful:
./update-hyprland.sh --install
```

### Upgrading Individual Components

```bash
# Update only core libraries (often needed for new Hyprland versions)
./update-hyprland.sh --fetch-latest --install --only hyprutils,hyprlang

# Update aquamarine specifically
./update-hyprland.sh --set AQUAMARINE=v0.9.3 --install --only aquamarine
```

### Selective Updates

```bash
# Install everything except Qt components
./update-hyprland.sh --install --skip hyprland-qt-support,hyprland-qtutils

# Install only specific components
./update-hyprland.sh --install --only hyprland,aquamarine
```

## Dry-Run Testing

### Why Use Dry-Run?
- Test compilation compatibility before installing
- Validate version combinations
- Debug build issues without system changes
- CI/CD pipeline integration

### Basic Dry-Run Usage

```bash
# Test current tag configuration
./update-hyprland.sh --dry-run

# Test with latest GitHub releases
./update-hyprland.sh --fetch-latest --dry-run

# Test specific version
./update-hyprland.sh --set HYPRLAND=v0.51.1 --dry-run
```

### Advanced Dry-Run Testing

```bash
# Use alternative summary format
./update-hyprland.sh --via-helper

# Test with dependencies installation
./dry-run-build.sh --with-deps

# Test only specific components
./dry-run-build.sh --only hyprland,aquamarine
```

### Dry-Run Limitations
- **Dependencies still install**: apt operations run to ensure compilation succeeds
- **pkg-config requirements**: Some components need system-installed prerequisites
- **No system changes**: No files installed to /usr/local or /usr

## Log Management

### Log Location
All build activities generate timestamped logs in:
```
Install-Logs/
├── 01-Hyprland-Install-Scripts-YYYY-MM-DD-HHMMSS.log  # Main install log
├── install-DD-HHMMSS_module-name.log                   # Per-module logs
├── build-dry-run-YYYY-MM-DD-HHMMSS.log                # Dry-run summary
└── update-hypr-YYYY-MM-DD-HHMMSS.log                  # Update tool summary
```

### Log Analysis
```bash
# View most recent install log
ls -t Install-Logs/*.log | head -1 | xargs less

# Check for errors in specific module
grep -i error Install-Logs/install-*hyprland*.log

# View dry-run summary
cat Install-Logs/build-dry-run-*.log
```

### Log Retention
- Logs accumulate over time for historical reference
- Manual cleanup recommended periodically:
```bash
# Keep only logs from last 30 days
find Install-Logs/ -name "*.log" -mtime +30 -delete
```

## Advanced Usage

### Tag Management

#### Backup and Restore
```bash
# Tags are automatically backed up on changes
# Restore most recent backup
./update-hyprland.sh --restore --dry-run
```

#### Multiple Version Sets
```bash
# Save current configuration
cp hypr-tags.env hypr-tags-stable.env

# Try experimental versions
./update-hyprland.sh --fetch-latest --dry-run

# Restore stable if needed
cp hypr-tags-stable.env hypr-tags.env
```

### Environment Integration

#### Custom PKG_CONFIG_PATH
```bash
# Ensure /usr/local takes precedence
export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
./update-hyprland.sh --install
```

#### Parallel Builds
```bash
# Control build parallelism (default: all cores)
export MAKEFLAGS="-j4"
./update-hyprland.sh --install
```

### Development Workflow

#### Testing New Releases
```bash
# 1. Create test environment
cp hypr-tags.env hypr-tags.backup

# 2. Test new version
./update-hyprland.sh --set HYPRLAND=v0.52.0 --dry-run

# 3. Install if successful
./update-hyprland.sh --install

# 4. Rollback if issues
./update-hyprland.sh --restore --install
```

#### Component Development
```bash
# Install dependencies only
./update-hyprland.sh --with-deps --dry-run

# Manual module testing
DRY_RUN=1 ./install-scripts/hyprland.sh

# Check logs for specific module
tail -f Install-Logs/install-*hyprland*.log
```

## Troubleshooting

### Common Issues

#### CMake Configuration Fails
**Symptoms**: "Package dependency requirement not satisfied"

**Solutions**:
```bash
# Install missing prerequisites
./update-hyprland.sh --install --only wayland-protocols-src,hyprutils,hyprlang

# Clear build cache
rm -rf hyprland aquamarine hyprutils hyprlang

# Retry installation
./update-hyprland.sh --install --only hyprland
```

#### Compilation Errors
**Symptoms**: "too many errors emitted"

**Solutions**:
```bash
# Update core dependencies first
./update-hyprland.sh --fetch-latest --install --only hyprutils,hyprlang

# Check for API mismatches in logs
grep -A5 -B5 "error:" Install-Logs/install-*hyprland*.log
```

#### Tag Not Found
**Symptoms**: "Remote branch X not found"

**Solutions**:
```bash
# Check available tags
git ls-remote --tags https://github.com/hyprwm/Hyprland

# Use confirmed existing tag
./update-hyprland.sh --set HYPRLAND=v0.50.1 --install
```

### Debug Steps

1. **Check system compatibility**:
   ```bash
   # Verify Debian version
   cat /etc/os-release
   
   # Ensure deb-src enabled
   grep -E "^deb-src" /etc/apt/sources.list
   ```

2. **Verify environment**:
   ```bash
   # Check current tags
   cat hypr-tags.env
   
   # Test dry-run first
   ./update-hyprland.sh --dry-run --only hyprland
   ```

3. **Analyze logs**:
   ```bash
   # Most recent errors
   grep -i "error\|fail" Install-Logs/*.log | tail -20
   
   # Module-specific issues
   ls -la Install-Logs/install-*[component]*.log
   ```

### Getting Help

1. **Check logs**: Always review Install-Logs/ for detailed error information
2. **Test dry-run**: Use --dry-run to validate before installing
3. **Community support**: Submit issues with relevant log excerpts
4. **Documentation**: Refer to main project README.md for base requirements

## Migration from Previous Versions

### Existing Installations
The new tools work alongside existing installations:

```bash
# Update existing installation
./update-hyprland.sh --install

# Test without affecting current system
./update-hyprland.sh --dry-run
```

### Converting to Tag Management
```bash
# Current versions are saved to hypr-tags.env automatically
# Verify with:
cat hypr-tags.env

# Modify versions as needed:
./update-hyprland.sh --set HYPRLAND=v0.51.1
```

The enhanced workflow provides better control, testing capabilities, and automation while maintaining full compatibility with the original installation process.