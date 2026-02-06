#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Nvidia - Check Readme for more details for the drivers #
# UBUNTU USERS, FOLLOW README!

set -euo pipefail

DRY_RUN=0
CHANGES=()

# Default Debian repo packages (can be older than NVIDIA repo)
nvidia_pkg=(
  nvidia-driver
  firmware-misc-nonfree
  nvidia-kernel-dkms
  linux-headers-$(uname -r)
  libnvidia-egl-wayland1
  libva-wayland2
  libnvidia-egl-wayland1
  nvidia-vaapi-driver
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
  echo "Failed to source Global_functions.sh"
  exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"
MLOG="install-$(date +%d-%H%M%S)_nvidia2.log"

# ---------------- helpers ----------------
run_cmd() {
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] $*"
  else
    eval "$@"
  fi
}

record_change() {
  # $1: message
  if [ "$DRY_RUN" -eq 0 ]; then
    CHANGES+=("$1")
  fi
}

_which() { command -v "$1" >/dev/null 2>&1; }

_detect_cuda_suite() {
  # We only support Debian 13+; use debian13 path for testing/unstable as well
  local codename
  codename=$(. /etc/os-release; echo "${DEBIAN_CODENAME:-${VERSION_CODENAME:-}}")
  case "$codename" in
    trixie|sid) echo "debian13" ;;
    *) echo "debian13" ;;
  esac
}

detect_variant() {
  if dpkg -l | grep -q -E '^ii\s+nvidia-open\b'; then echo open; return; fi
  if dpkg -l | grep -q -E '^ii\s+cuda-drivers\b'; then echo nvidia; return; fi
  if dpkg -l | grep -q -E '^ii\s+nvidia-driver\b'; then echo debian; return; fi
  echo none
}

_apt_update_once() {
  echo -e "${INFO} Refreshing APT package lists..."
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] sudo apt update"
  else
    sudo apt update 2>&1 | tee -a "$LOG"
  fi
}

apt_install() {
  # pass packages as args
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] sudo apt-get -s install -y $*"
    sudo apt-get -s install -y "$@" >/dev/null || true
  else
    sudo apt install -y "$@" 2>&1 | tee -a "$LOG"
    record_change "apt install: $*"
  fi
}

apt_remove() {
  # pass packages as args
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[DRY-RUN] sudo apt-get -s remove --purge -y $*"
    sudo apt-get -s remove --purge -y "$@" >/dev/null || true
  else
    sudo apt remove --purge -y "$@" 2>&1 | tee -a "$LOG" || true
    sudo apt autoremove -y 2>&1 | tee -a "$LOG" || true
    record_change "apt remove --purge: $*"
  fi
}

# Ensure a list of packages are installed (skip any already present)
ensure_packages() {
  local missing=()
  for pkg in "$@"; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
      missing+=("$pkg")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo -e "${INFO} Installing required packages: ${YELLOW}${missing[*]}${RESET}"
    apt_install "${missing[@]}"
  fi
}

# Try to ensure kernel headers for the running kernel are available
ensure_kernel_headers() {
  local kv pkg_exact
  kv=$(uname -r)
  pkg_exact="linux-headers-${kv}"

  # Many Debian systems track the meta package; try exact first, then meta
  if dpkg -s "$pkg_exact" >/dev/null 2>&1; then
    echo -e "${OK} Kernel headers already installed for ${YELLOW}${kv}${RESET}"
    return 0
  fi

  echo -e "${INFO} Ensuring kernel headers for ${YELLOW}${kv}${RESET} ..."
  if ! apt_install "$pkg_exact"; then
    # Fallback to common meta packages
    if dpkg --print-architecture | grep -qE 'amd64|arm64|i386'; then
      apt_install linux-headers-$(dpkg --print-architecture 2>/dev/null | sed 's/.*/amd64/') >/dev/null 2>&1 || true
    fi
    # Generic fallback
    apt_install linux-headers-amd64 || true
  fi
}

# Preflight: headers, toolchain, utilities used by this script
preflight_check() {
  echo -e "${INFO} Running preflight checks ..."
  _apt_update_once
  # Basic toolchain and helpers; mesa-utils for glxinfo used in verification; pciutils for lspci
  ensure_packages build-essential dkms wget ca-certificates mesa-utils pciutils
  ensure_kernel_headers || true

  # Secure Boot warning (drivers may fail to load without signing)
  if _which mokutil && mokutil --sb-state 2>/dev/null | grep -qi enabled; then
    echo -e "${WARN} Secure Boot appears ${YELLOW}ENABLED${RESET}. You may need to enroll a Machine Owner Key (MOK) and sign NVIDIA modules."
  fi
}

remove_conflicting_for_target() {
  local target="$1"
  case "$target" in
    nvidia) apt_remove nvidia-open nvidia-driver ;;
    open)   apt_remove cuda-drivers nvidia-driver ;;
    debian) apt_remove cuda-drivers nvidia-open ;;
  esac
}

_install_via_debian() {
  echo -e "${INFO} Using Debian repo packages (may be older on testing/unstable)."
  _apt_update_once
  printf "${YELLOW} Installing ${SKY_BLUE}NVIDIA packages from Debian${RESET} ...\n"
  for NVIDIA in "${nvidia_pkg[@]}"; do
    apt_install "$NVIDIA"
  done
}

_install_via_nvidia_repo_with() {
  # $1: package to install from NVIDIA repo (e.g., cuda-drivers or nvidia-open)
  local package="$1"
  local suite pkg url
  suite=$(_detect_cuda_suite)
  pkg="cuda-keyring_1.1-1_all.deb"
  url="https://developer.download.nvidia.com/compute/cuda/repos/${suite}/x86_64/${pkg}"

  echo -e "${INFO} Ensuring NVIDIA CUDA repo for ${YELLOW}${suite}${RESET} is configured ..." | tee -a "$LOG"

  # Skip keyring install if already present
  if dpkg -s cuda-keyring >/dev/null 2>&1 || [ -f "/etc/apt/sources.list.d/cuda-${suite}-x86_64.sources" ]; then
    echo -e "${OK} NVIDIA CUDA repo already configured." | tee -a "$LOG"
  else
    rm -f "$pkg"
    if [ "$DRY_RUN" -eq 1 ]; then
      echo "[DRY-RUN] wget -q '$url' -O '$pkg'"
    else
      if ! wget -q "$url" -O "$pkg"; then
        echo -e "${ERROR} Failed to download $pkg from $url" | tee -a "$LOG"
        return 1
      fi
    fi
    run_cmd "sudo dpkg -i '$pkg' 2>&1 | tee -a '$LOG'"
    record_change "configured NVIDIA CUDA repo (${suite})"
    _apt_update_once
  fi

  echo -e "${INFO} Installing ${YELLOW}${package}${RESET} from NVIDIA repo ..." | tee -a "$LOG"
  apt_install "${package}"
}

_install_via_nvidia_repo() {
  _install_via_nvidia_repo_with "cuda-drivers"
}

_install_via_nvidia_open() {
  _install_via_nvidia_repo_with "nvidia-open"
}

_prompt_for_mode() {
  local mode_input=""
  echo
  echo -e "${WARN} Default installs ${YELLOW}Debian repo NVIDIA drivers${RESET} (often older)."
  echo -e "${WARN} ${YELLOW}NVIDIA driver options are currently in development${RESET}."
  echo -e "${WARN} If you have a current‑generation NVIDIA GPU, ${YELLOW}do NOT use Debian-based drivers${RESET}."
  echo -e "      Choose an NVIDIA CUDA repo option below, or install drivers manually and re-run the Debian Hyprland install."
  echo -e "${CAT} Choose installation source:"
  echo -e "  [D] Debian repo (default) — installs ${YELLOW}nvidia-driver${RESET} and related packages"
  echo -e "  [N] NVIDIA CUDA repo — installs ${YELLOW}cuda-drivers${RESET} (proprietary)"
  echo -e "  [O] NVIDIA CUDA repo — installs ${YELLOW}nvidia-open${RESET} (open kernel modules)"
  while true; do
    read -r -p "Select an option: D=Debian (default), N=NVIDIA proprietary, O=Open: " mode_input || true
    case "${mode_input,,}" in
      ""|d|debian) echo "debian"; return ;;
      n|nv|nvidia|proprietary) echo "nvidia"; return ;;
      o|open) echo "open"; return ;;
      h|help|\?)
        echo -e "Enter D for Debian-packaged drivers, N for NVIDIA's proprietary drivers, or O for NVIDIA's open kernel modules." ;;
      *)
        echo -e "${WARN} Invalid choice. Please enter D, N, or O." ;;
    esac
  done
}

print_header() {
  echo -e "${INFO} NVIDIA driver setup (Debian 13+/testing/unstable supported)" \
          "\n${INFO} Logs: ${YELLOW}$LOG${RESET}"
}

print_gpu_info() {
  echo -e "${INFO} Detecting NVIDIA GPU..."
  if _which nvidia-smi; then
    local line
    line=$(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null | head -n1 || true)
    if [ -n "$line" ]; then
      echo -e "${OK} Detected (nvidia-smi): ${YELLOW}$line${RESET}"
      return
    fi
  fi
  if _which lspci; then
    local l
    l=$(lspci -nnk | awk '/VGA|3D|Display/ && /NVIDIA/ {print; getline; print}' | head -n2)
    if [ -n "$l" ]; then
      echo -e "${OK} Detected (lspci):\n${YELLOW}$l${RESET}"
      return
    fi
  fi
  echo -e "${NOTE} Could not positively identify an NVIDIA GPU (drivers may not be loaded yet)."
}

print_usage() {
  cat <<EOF
Usage: ${0##*/} [--mode=debian|nvidia|open] [--switch] [--force] [-n|--dry-run] [-h|--help]

Description:
  Installs NVIDIA drivers on Debian 13+/testing/unstable.
  - Default path installs Debian-packaged drivers (may be older).
  - NVIDIA repo paths install the latest drivers from NVIDIA's CUDA repo.

Warning:
  The NVIDIA driver options are currently in development.
  If you have a current-generation NVIDIA GPU, do NOT use Debian-based drivers.
  Use one of the NVIDIA CUDA repo options (proprietary or open), or install drivers manually
  and re-run the Debian Hyprland install.

Interactive options (shown if no --mode is provided):
  D  Debian repo — installs nvidia-driver and related packages
  N  NVIDIA CUDA repo — installs cuda-drivers (proprietary)
  O  NVIDIA CUDA repo — installs nvidia-open (open kernel modules)

Flags:
  --mode=debian   Use Debian repository packages
  --mode=nvidia   Use NVIDIA CUDA repo (proprietary)
  --mode=open     Use NVIDIA CUDA repo (open kernel modules)
  --switch        Switch from the current variant to the one specified by --mode (removes conflicting meta packages)
  --force         Do not exit early when already configured; re-run installs
  -n, --dry-run   Simulate actions; do not modify the system
  -h, --help      Show this help and exit

Examples:
  ${0##*/}
  ${0##*/} --mode=nvidia
  ${0##*/} --mode=open
  ${0##*/} --mode=nvidia --switch     # switch from Debian or open to proprietary
  ${0##*/} --mode=debian --force      # re-run Debian path even if already configured
EOF
}

# ---------------- main ----------------
print_header
print_gpu_info

# Parse flags
MODE=""
SWITCH=""
FORCE=""
for arg in "$@"; do
  case "$arg" in
    --mode=debian) MODE="debian" ;;
    --mode=nvidia) MODE="nvidia" ;;
    --mode=open)   MODE="open" ;;
    --switch)      SWITCH=1 ;;
    --force)       FORCE=1 ;;
    -n|--dry-run)  DRY_RUN=1 ;;
    -h|--help)
      print_usage
      exit 0
      ;;
  esac
 done

if [ -z "$MODE" ]; then
  MODE=$(_prompt_for_mode)
fi

# Early exit or switch handling
variant_now=$(detect_variant)
if [ -z "$SWITCH" ] && [ -z "$FORCE" ] && [ "$DRY_RUN" -ne 1 ] && [ "$variant_now" = "$MODE" ]; then
  echo -e "${OK} NVIDIA is already configured for mode: ${YELLOW}${MODE}${RESET}"
  echo -e "${INFO} Use --force to re-run installs, or --switch to change variants."
  exit 0
fi

if [ -n "$SWITCH" ] && [ "$variant_now" != none ] && [ "$variant_now" != "$MODE" ]; then
  echo -e "${INFO} Switching from ${YELLOW}$variant_now${RESET} to ${YELLOW}$MODE${RESET} ..."
  remove_conflicting_for_target "$MODE"
fi

# Ensure headers/tooling before installing drivers (skipped on early-exit above)
preflight_check || true

case "$MODE" in
  debian)
    _install_via_debian
    ;;
  nvidia)
    _install_via_nvidia_repo
    ;;
  open)
    _install_via_nvidia_open
    ;;
  *)
    echo -e "${ERROR} Unknown mode: $MODE"; exit 1;
    ;;
 esac

# ---------------- common post-install tweaks ----------------
# Function to add a value to a configuration file if not present
add_to_file() {
    local config_file="$1"
    local value="$2"
    if ! sudo grep -q "$value" "$config_file" 2>/dev/null; then
        echo "Adding $value to $config_file" | tee -a "$LOG"
        run_cmd "sudo sh -c 'echo \"$value\" >> \"$config_file\"'"
        record_change "appended to $config_file"
    else
        echo "$value is already present in $config_file." | tee -a "$LOG"
    fi
}

printf "${YELLOW} Applying ${SKY_BLUE}NVIDIA boot/module settings${RESET} ...\n"

  # Additional options to add to GRUB_CMDLINE_LINUX
  additional_options="rd.driver.blacklist=nouveau modprobe.blacklist=nouveau nvidia-drm.modeset=1 rcutree.rcu_idle_gp_delay=1"

  # Check if additional options are already present in GRUB_CMDLINE_LINUX
  if grep -q "GRUB_CMDLINE_LINUX.*$additional_options" /etc/default/grub 2>/dev/null; then
    echo "GRUB_CMDLINE_LINUX already contains the additional options" | tee -a "$LOG"
  else
    # Append the additional options to GRUB_CMDLINE_LINUX
    if [ -f /etc/default/grub ]; then
      run_cmd "sudo sed -i 's/GRUB_CMDLINE_LINUX=\"/GRUB_CMDLINE_LINUX=\"$additional_options /' /etc/default/grub"
      echo "Added the additional options to GRUB_CMDLINE_LINUX" | tee -a "$LOG"
      record_change "updated GRUB_CMDLINE_LINUX in /etc/default/grub"
      run_cmd "sudo update-grub 2>&1 | tee -a '$LOG'"
      record_change "update-grub"
    else
      echo -e "${NOTE} /etc/default/grub not found; skipping GRUB update" | tee -a "$LOG"
    fi
  fi
    
  # Define the configuration file and the line to add
  config_file="/etc/modprobe.d/nvidia.conf"
  line_to_add="""
options nvidia-drm modeset=1 fbdev=1
options nvidia NVreg_PreserveVideoMemoryAllocations=1
"""

  # Ensure the config file exists
  if [ ! -e "$config_file" ]; then
      echo "Creating $config_file" | tee -a "$LOG"
      run_cmd "sudo touch '$config_file' 2>&1 | tee -a '$LOG'"
      record_change "created $config_file"
  fi

  add_to_file "$config_file" "$line_to_add"

  # Add NVIDIA modules to initramfs configuration
  modules_to_add="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
  modules_file="/etc/initramfs-tools/modules"

  if [ -e "$modules_file" ]; then
    add_to_file "$modules_file" "$modules_to_add" 2>&1 | tee -a "$LOG"
    run_cmd "sudo update-initramfs -u 2>&1 | tee -a '$LOG'"
    record_change "update-initramfs -u"
  else
    echo "Modules file ($modules_file) not found." 2>&1 | tee -a "$LOG"
  fi

# ---------------- post-install verification ----------------
post_install_verify() {
  echo -e "${INFO} Verifying NVIDIA installation..."

  # Determine installed variant
  local variant="unknown"
  if dpkg -l | grep -q -E '^ii\s+nvidia-open\b'; then
    variant="open (NVIDIA CUDA repo)"
  elif dpkg -l | grep -q -E '^ii\s+cuda-drivers\b'; then
    variant="proprietary (NVIDIA CUDA repo)"
  elif dpkg -l | grep -q -E '^ii\s+nvidia-driver\b'; then
    variant="debian-packaged"
  fi
  echo -e "${OK} Driver source detected: ${YELLOW}${variant}${RESET}"

  # Module load status
  local loaded="no"
  if lsmod | grep -q '^nvidia\b'; then loaded="yes"; fi
  echo -e "${INFO} Kernel module loaded: ${YELLOW}${loaded}${RESET}"
  if [ "$loaded" != "yes" ]; then
    echo -e "${NOTE} NVIDIA module not loaded. A reboot is often required after driver install."
  fi

  # nvidia-smi (if available)
  if _which nvidia-smi; then
    local smi
    smi=$(nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null | head -n1 || true)
    if [ -n "$smi" ]; then
      echo -e "${OK} nvidia-smi: ${YELLOW}${smi}${RESET}"
    else
      echo -e "${NOTE} nvidia-smi present but returned no GPU entries."
    fi
  else
    echo -e "${NOTE} nvidia-smi not found; driver utilities may not be installed yet."
  fi

  # GL stack info (best-effort)
  if _which glxinfo; then
    echo -e "${INFO} OpenGL summary:";
    glxinfo -B 2>/dev/null | grep -E 'OpenGL (vendor|renderer|version)' || true
  fi
}

if [ "$DRY_RUN" -eq 1 ]; then
  echo "[DRY-RUN] Would run post-install verification (nvidia-smi, module status, glxinfo)."
else
  post_install_verify || true
fi

# ---------------- summary ----------------
if [ "$DRY_RUN" -eq 1 ]; then
  echo -e "${INFO} Dry-run mode: no changes made."
else
  if [ "${#CHANGES[@]}" -eq 0 ]; then
    echo -e "${OK} No changes made."
  else
    echo -e "${OK} Changes applied:"
    for c in "${CHANGES[@]}"; do
      echo " - $c"
    done
  fi
fi

printf "\n%.0s" {1..2}
