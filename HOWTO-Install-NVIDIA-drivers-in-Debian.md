# HOWTO: Install NVIDIA drivers on Debian 13+/testing/unstable

This guide explains how to install and maintain NVIDIA GPU drivers on Debian 13 (trixie), testing, and unstable using `install-scripts/nvidia.sh`.

Supported scope

- Debian 13 (trixie), Debian testing, Debian unstable.
- Current-generation NVIDIA GPUs are best served by NVIDIA’s own repository (cuda-drivers or nvidia-open). Avoid Debian’s `nvidia-driver` for new cards.

Quick start

```bash
# Interactive (recommended first run). Default = Open kernel modules (nvidia-open)
install-scripts/nvidia.sh

# Install from NVIDIA CUDA repo (open kernel modules) — DEFAULT
install-scripts/nvidia.sh --mode=open

# Install from NVIDIA CUDA repo (proprietary)
install-scripts/nvidia.sh --mode=nvidia

# Install Debian-packaged drivers (older; OK for very old GPUs < 2000-series)
install-scripts/nvidia.sh --mode=debian
```

## What the script does

- Detects your GPU (prefers `nvidia-smi`, falls back to `lspci`).
- Offers three installation paths (see below).
- For NVIDIA repo paths:
    - Ensures the CUDA APT repo/keyring for Debian 13 is configured (idempotent).
    - Installs the selected meta package: `cuda-drivers` (proprietary) or `nvidia-open` (open kernel modules).
- Adds kernel parameters to blacklist nouveau and enable DRM KMS, updates GRUB, and updates initramfs.
- Runs a post-install verification (driver source, module loaded, `nvidia-smi`/OpenGL summary).
- Prints an end-of-run summary of changes.

## Options and when to use them

- NVIDIA CUDA repo — open kernel modules (`--mode=open`) [Default]
    - Installs `nvidia-open` from NVIDIA’s APT repo. Recommended for Wayland/Hyprland, smoother kernel updates, and RTX 5000-series+ GPUs (required).
- NVIDIA CUDA repo — proprietary (`--mode=nvidia`)
    - Installs `cuda-drivers` from NVIDIA’s APT repo. "Battle‑tested" closed modules; fine for many 2000/3000/4000 series setups; may involve DKMS rebuilds on kernel updates.
- Debian repo — packaged by Debian (`--mode=debian`)
    - Installs `nvidia-driver` and related packages from Debian. Older but suitable for very old GPUs (< 2000‑series).

### Open vs. Proprietary: Feature comparison

| Feature | Proprietary (Closed) | Open Kernel Modules |
| --- | --- | --- |
| Kernel updates | Higher risk of DKMS failure | Smoother, more "native" feel |
| Wayland/Hyprland | High performance, "battle‑tested" | Better future‑proofing, GSP usage |
| CUDA / Docker | Gold standard | Identical (user‑space is the same) |

Notes:
- "Identical" refers to the CUDA user‑space stack; the kernel modules differ.
- Both paths support CUDA, container stacks, and modern compositors; the open modules reduce DKMS friction.

### Why default to Open on testing/SID

- Debian testing/unstable kernels change frequently; open modules track kernel interfaces better and avoid DKMS breakage.
- Better long‑term support for Wayland/Hyprland workflows.
- Keeps user‑space identical to proprietary path for CUDA/Docker workflows.

### Quick decision guide

- RTX 5000‑series and newer: choose Open (`--mode=open`).
- Very old GPUs (< 2000‑series): choose Debian (`--mode=debian`).
- Everything else (2000–4000): Open recommended; Proprietary is also viable.

## Important warnings shown by the script

When run interactively, the script displays this notice:

```
[INFO] Default installs NVIDIA CUDA repo — nvidia-open (open kernel modules).
[INFO] Guidance:
  - RTX 5000-series and newer: use Open (required).
  - < 2000-series (very old cards): prefer Debian repo driver.
  - Others (2000–4000): Open recommended; Proprietary also available.
[ACTION] Choose installation source:
  [O] NVIDIA CUDA repo — nvidia-open (open kernel modules) [default]
  [N] NVIDIA CUDA repo — cuda-drivers (proprietary)
  [D] Debian repo — nvidia-driver (packaged)
Select [O/n/d]: _
```

## Non-interactive flags

- `--mode=debian|nvidia|open` Selects installation path.
- `--switch` Switch from your current variant to the target mode (removes conflicting meta-packages).
- `--force` Don’t exit early if already configured; re-run installs.
- `-n, --dry-run` Simulate actions (uses `apt-get -s`, prints changes without applying).
- `-h, --help` Show usage, options, and examples.

Examples

```bash
# Switch from Debian-packaged driver to proprietary CUDA repo driver
install-scripts/nvidia.sh --mode=nvidia --switch

# Re-run Debian path even if already configured
install-scripts/nvidia.sh --mode=debian --force

# Dry-run the open-kernel flow without making changes
install-scripts/nvidia.sh --mode=open --dry-run
```

## Sample outputs

GPU detection

```
[INFO] Detecting NVIDIA GPU...
[OK] Detected (nvidia-smi): NVIDIA GeForce RTX 3050, 590.48.01
```

(If drivers are not yet loaded, it falls back to `lspci` output.)

Post-install verification

```
[INFO] Verifying NVIDIA installation...
[OK] Driver source detected: proprietary (NVIDIA CUDA repo)
[INFO] Kernel module loaded: yes
[OK] nvidia-smi: NVIDIA GeForce RTX 3050, 590.48.01
[INFO] OpenGL summary:
OpenGL vendor string: NVIDIA Corporation
OpenGL renderer string: NVIDIA GeForce RTX 3050/PCIe/SSE2
OpenGL core profile version string: 4.6.0 NVIDIA 590.48.01
```

End-of-run summary

```
[OK] No changes made.
```

Or, when changes occurred:

```
[OK] Changes applied:
 - configured NVIDIA CUDA repo (debian13)
 - apt install: cuda-drivers
 - updated GRUB_CMDLINE_LINUX in /etc/default/grub
 - update-grub
 - update-initramfs -u
```

Early exit when re-running

```
[OK] NVIDIA is already configured for mode: nvidia
[INFO] Use --force to re-run installs, or --switch to change variants.
```

## What gets changed on your system

- APT: Adds/uses NVIDIA’s CUDA repo (Debian 13 path) via `cuda-keyring` (only if missing).
- GRUB: Appends `rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1` to `GRUB_CMDLINE_LINUX` and runs `update-grub`.
- Modules: Ensures `nvidia nvidia_modeset nvidia_uvm nvidia_drm` are added to `/etc/initramfs-tools/modules`, then runs `update-initramfs -u`.

All changes are idempotent; re-running won’t duplicate entries. The script prints a clear summary of what, if anything, changed.

## Troubleshooting

- Reboot required: After installing drivers, a reboot is often needed for the `nvidia` kernel module to load.
- `nvidia-smi` missing: If `nvidia-smi` isn’t found right away, ensure the installation completed and reboot.
- Switching variants: Use `--switch` with `--mode=...` to change between Debian, proprietary CUDA, and open kernel module variants; the script removes conflicting meta-packages first.

## Uninstall / switching notes

The meta-packages are mutually exclusive per variant:

- Debian: `nvidia-driver`
- Proprietary CUDA: `cuda-drivers`
- Open modules: `nvidia-open`

When switching, the script purges the conflicting meta-packages and runs `apt autoremove` before installing the target.

---

If you prefer to install drivers manually (outside the script), do so first, then re-run the Debian Hyprland installer, say `No` to installing NVIDIA, to continue with the rest of the setup.
