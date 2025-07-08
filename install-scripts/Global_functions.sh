#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Global Functions for Scripts #

set -euo pipefail
IFS=$'\n\t'

# See first comment of answer in https://stackoverflow.com/a/53183593
# Get directory of this script
SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

PARENT_DIR=$SCRIPT_DIR/..

source "$SCRIPT_DIR/colors.sh" || {
    echo "Failed to source $SCRIPT_DIR/colors.sh"
    exit 1
}

source "$SCRIPT_DIR/parse_args.sh" || {
    echo "${RED} Failed to source $SCRIPT_DIR/parse_args.sh"
    exit 1
}

# Create Directory for Install Logs
if [[ $DRY -eq 0 && ! -d "$PARENT_DIR"/Install-Logs ]]; then
    mkdir "$PARENT_DIR"/Install-Logs
elif [[ $DRY -eq 1 ]]; then
    echo "${NOTE} Not creating directory $PARENT_DIR/Install-Logs"
fi

# Print $1 amount of newlines
newlines() {
    for ((i = 1; i <= "$1"; i++)); do
        printf "\n"
    done
}

# Verbose logging for when using the --verbose or -v option
verbose_log() {
    if [[ "$VERBOSE" == 1 ]]; then
        echo "${GRAY}[VERBOSE NOTE]${RESET} $1"
    fi
}

# Function to check if the system is Ubuntu
is_ubuntu() {
    # Check for 'Ubuntu' in /etc/os-release
    if grep -q 'Ubuntu' /etc/os-release; then
        return 0
    fi
    return 1
}

execute_script() {
    local script="$1"
    local script_path="$SCRIPT_DIR/$script"
    if [ -f "$script_path" ]; then
        verbose_log "Attempting to change permissions of file to be executable: $script_path"
        if [[ $PEDANTIC_DRY -eq 1 ]]; then
            echo "${NOTE} I won't make $script_path executable."
        else
            chmod +x "$script_path"
        fi
        if [ -x "$script_path" ]; then
            verbose_log "Executing file: $script_path"
            env "$script_path"
        else
            echo "${WARN} Failed to make script '$script' executable.${RESET}" | tee -a "$LOG"
        fi
    else
        echo "${WARN} Script '$script' not found in '$SCRIPT_DIR'.${RESET}" | tee -a "$LOG"
    fi
}

# Function to load preset file
load_preset() {
    echo "✅ Loading preset: $1"
    # shellcheck source=../preset.sh
    source "$1" || {
        echo "${ERROR} Failed to execute $(realpath "$1")"
        exit 1
    }
}

# List of services to check for active login managers
services=("gdm.service" "gdm3.service" "lightdm.service" "lxdm.service")

# Function to check if any login services are active
check_services_running() {
    active_services=() # Array to store active services
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            verbose_log "Adding $svc as an active service that should be inactive"
            active_services+=("$svc")
        fi
    done

    verbose_log "Active services count: ${#active_services[@]}"
    if [ ${#active_services[@]} -gt 0 ]; then
        verbose_log "These interfering active services were found: $(printf "%s\n" "${active_services[@]}")"
        return 1
    else
        verbose_log "No notorious active services were found."
        return 0
    fi
}

# Check if package is installed with apt and friends (returns 0 if so and 1 if not)
check_if_installed_with_apt() {
    # Reliable way to check if package is installed, with Perl regex to support lookaheads
    apt list "$1" --installed | grep -qP '^[^\/]*(?=.*\[installed)'
    return $?
}

# Show progress function
show_progress() {
    local pid=$1
    local package_name=$2
    local spin_chars=("●○○○○○○○○○" "○●○○○○○○○○" "○○●○○○○○○○" "○○○●○○○○○○" "○○○○●○○○○" "○○○○○●○○○○" "○○○○○○●○○○" "○○○○○○○●○○" "○○○○○○○○●○" "○○○○○○○○○●")
    local i=0

    tput civis
    printf "\r${INFO} Installing ${YELLOW}%s${RESET} ..." "$package_name"

    while ps -p "$pid" &>/dev/null; do
        printf "\r${INFO} Installing ${YELLOW}%s${RESET} %s" "$package_name" "${spin_chars[i]}"
        i=$(((i + 1) % 10))
        sleep 0.3
    done

    printf "\r${INFO} Installing ${YELLOW}%s${RESET} ... Done!%-20s \n\n" "$package_name" ""
    tput cnorm
}

# Function for installing packages with a progress bar
install_package() {
    if check_if_installed_with_apt "$1"; then
        echo "${INFO} ${MAGENTA}$1${RESET} is already installed. Skipping..."
    else
        if [[ $PEDANTIC_DRY -eq 1 ]]; then
            echo "${NOTE} I won't install $1 even though it is required."
        else
            # Install with apt but preserve apt markings. However, --mark-auto does not work, so this regexp workaround has to be used until the bug becomes fixed: https://bugs.launchpad.net/ubuntu/+source/apt/+bug/2100937
            local markauto=0
            apt-mark showauto | grep -qP "^$1(:.+)?$" && {
                verbose_log "Preserving apt marking for package $1"
                markauto=1
            }
            verbose_log "Installing $1 with sudo apt install --assume-yes $1"
            (
                # Use stdbuf -oL for line buffering (append as lines go by instead of when it is all done) to the log file
                stdbuf -oL sudo apt install --assume-yes "$1" 2>&1
            ) >>"$LOG" 2>&1 &
            PID=$!
            show_progress $PID "$1"

            # Double check if the package successfully installed
            if check_if_installed_with_apt "$1"; then
                echo -e "\e[1A\e[K${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
            else
                echo -e "\e[1A\e[K${ERROR} ${YELLOW}$1${RESET} failed to install. Please check the install.log. You may need to install it manually. Sorry, I have tried :("
            fi

            [[ $markauto -eq 1 ]] && {
                echo "${ACTION}Setting package $1 to auto to preserve its apt-mark status"
                (
                    sudo apt-mark auto "$1" 2>&1
                ) >>"$LOG" 2>&1
            }
        fi
    fi
    verbose_log "Done with install_package $1"
}

# Short synonym for install_package function
apt_install() {
    install_package "$@"
}

# apt install --no-recommends
apt_install_no_recommends() {
    if check_if_installed_with_apt "$1"; then
        echo "${INFO} ${MAGENTA}$1${RESET} is already installed. Skipping..."
    else
        if [[ $PEDANTIC_DRY -eq 1 ]]; then
            echo "${NOTE} I won't install $1 even though it is required."
        else
            # Install with apt but preserve apt markings. However, --mark-auto does not work, so this regexp workaround has to be used until the bug becomes fixed: https://bugs.launchpad.net/ubuntu/+source/apt/+bug/2100937
            local markauto=0
            apt-mark showauto | grep -qP "^$1(:.+)?$" && {
                verbose_log "Preserving apt marking for package $1"
                markauto=1
            }
            verbose_log "Installing $1 with sudo apt install --no-install-recommends --assume-yes $1"
            (
                # Use stdbuf -oL for line buffering (append as lines go by instead of when it is all done) to the log file
                stdbuf -oL sudo apt install --no-install-recommends --assume-yes "$1" 2>&1
            ) >>"$LOG" 2>&1 &
            PID=$!
            show_progress $PID "$1"

            # Double check if the package successfully installed
            if check_if_installed_with_apt "$1"; then
                echo -e "\e[1A\e[K${OK} Package ${YELLOW}$1${RESET} has been successfully installed!"
            else
                echo -e "\e[1A\e[K${ERROR} ${YELLOW}$1${RESET} failed to install. Please check the install.log. You may need to install it manually. Sorry, I have tried :("
            fi

            [[ $markauto -eq 1 ]] && {
                echo "${ACTION}Setting package $1 to auto to preserve its apt-mark status"
                (
                    sudo apt-mark auto "$1" 2>&1
                ) >>"$LOG" 2>&1
            }
        fi
    fi
}

# Function for build dependencies with a progress bar
build_dep() {
    echo "${INFO} building dependencies for ${MAGENTA}$1${RESET} "
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I won't install $1 even though it is required."
    else
        (
            stdbuf -oL sudo apt build-dep --assume-yes "$1" 2>&1
        ) >>"$LOG" 2>&1 &
        PID=$!
        show_progress $PID "$1"
    fi
}

# Function for cargo install with a progress bar
cargo_install() {
    echo "${INFO} installing ${MAGENTA}$1${RESET} using cargo..."
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I won't install $1 using cargo even though it is required."
    else
        (
            stdbuf -oL cargo install "$1" 2>&1
        ) >>"$LOG" 2>&1 &
        PID=$!
        show_progress $PID "$1"
    fi
}

# Function for re-installing packages with a progress bar
re_install_package() {
    if [[ $PEDANTIC_DRY -eq 1 ]]; then
        echo "${NOTE} I won't reinstall $1."
    else
        (
            stdbuf -oL sudo apt install --reinstall --assume-yes "$1" 2>&1
        ) >>"$LOG" 2>&1 &

        PID=$!
        show_progress $PID "$1"

        if dpkg -l | grep -q -w "$1"; then
            echo -e "\e[1A\e[K${OK} Package ${YELLOW}$1${RESET} has been successfully re-installed!"
        else
            # Package not found, reinstallation failed
            echo "${ERROR} ${YELLOW}$1${RESET} failed to re-install. Please check the install.log. You may need to install it manually. Sorry, I have tried :("
        fi
    fi
}

# Short synonym for re_install_package function
apt_reinstall() {
    re_install_package "$@"
}

# Function for removing packages
uninstall_package() {
    local pkg="$1"

    # Checking if package is installed
    if sudo dpkg -l | grep -q -w "^ii  $1"; then
        echo "${NOTE} removing $pkg ..."
        if [[ $PURGE -eq 1 ]]; then
            if [[ $VERBOSE -eq 1 ]]; then
                sudo apt autopurge --assume-yes "$1" | tee -a "$LOG" 2>&1
            else
                sudo apt autopurge --assume-yes "$1" | tee -a "$LOG" 2>&1 | grep -v "error: target not found"
            fi
        else
            if [[ $VERBOSE -eq 1 ]]; then
                sudo apt autoremove --assume-yes "$1" | tee -a "$LOG" 2>&1
            else
                sudo apt autoremove --assume-yes "$1" | tee -a "$LOG" 2>&1 | grep -v "error: target not found"
            fi
        fi

        if ! dpkg -l | grep -q -w "^ii  $1"; then
            echo -e "\e[1A\e[K${OK} ${MAGENTA}$1${RESET} removed."
        else
            echo -e "\e[1A\e[K${ERROR} $pkg Removal failed. No actions required."
            return 1
        fi
    else
        echo "${INFO} Package $pkg not installed, skipping."
    fi
    return 0
}

# Short synonym for uninstall_package function
apt_remove() {
    uninstall_package "$@"
}

remove_file() {
    if [[ -f "$1" ]]; then
        if [[ $DRY -eq 1 ]]; then
            echo "${NOTE} I am not removing $1"
        else
            verbose_log "Removing file $1"
            if [[ $# -gt 1 && -n $2 ]]; then
                rm "$1" 2>&1 | tee -a "$2"
            else
                rm "$1" 2>&1
            fi
        fi
    else
        verbose_log "File $1 does not exist, so not removing it"
    fi
}

remove_dir() {
    # Sanity checker
    case $(realpath "$1") in
    /)
        echo "${ERROR} Attempting to remove root directory $1. Must be a bug in the code. Exiting..."
        exit 1
        ;;
    /usr | /usr/bin | /usr/local | /usr/local/bin | /etc | /home | /usr/lib | /usr/local/lib)
        echo "${ERROR} Attempting to remove system directory $1. Must be a bug in the code. Exiting..."
        exit 1
        ;;
    *)
        verbose_log "Directory $1 is probably safe to remove."
        ;;
    esac

    if [[ -d "$1" ]]; then
        if [[ $DRY -eq 1 ]]; then
            echo "${NOTE} I am not removing the directory $1"
        else
            verbose_log "Forcibly and recursively removing the directory $1"
            if [[ $# -gt 1 && -n $2 ]]; then
                sudo rm -rf "$1" 2>&1 | tee -a "$2"
            else
                sudo rm -rf "$1" 2>&1
            fi
        fi
    else
        verbose_log "Directory $1 does not exist, so not removing it"
    fi
}

# Essential function for automating building of repositories from hyprwm
# First arg: release version, second arg: name of repository, third arg: "cmake_build", "hyprland-qt-support", "hyprwayland-scanner", or "meson" build type, fourth arg: "cmake" or "meson" installation type, fifth arg: repository name (defaults to hyprwm)
build_from_git() {
    local install_prefix="/usr/local"
    # Change install_prefix to --dry-run-dir's value
    [[ $DRY -eq 1 ]] && install_prefix=$PARENT_DIR/faux-install-dir
    [[ $DRY_RUN_DIR_SET -eq 1 ]] && install_prefix=$DRY_RUN_DIR

    SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

    # Change the working directory to the parent directory of the script
    PARENT_DIR="$SCRIPT_DIR/.."

    #specific branch or release
    release="$1"

    cd "$PARENT_DIR" || {
        echo "${ERROR} Failed to change directory to $PARENT_DIR"
        exit 1
    }

    # Set the name of the log file to include the current date and time
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_$2.log"
    MLOG="install-$(date +%d-%H%M%S)_$2.log"

    # Check if directory exists and remove it
    remove_dir "$2"

    # Clone and build
    echo "${INFO} Installing ${YELLOW}$2 $release${RESET} ..."
    if [[ $NO_BUILD -eq 1 ]]; then
        echo "${NOTE} I am not cloning $2 and building it."
    else
        local name="hyprwm"
        [[ $# -gt 4 && -n $5 ]] && name=$5
        if git clone --recursive -b "$release" "https://github.com/$name/$2.git"; then
            cd "$2" || exit 1

            case "$3" in
            cmake_build)
                cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH="$install_prefix" -S . -B ./build
                cmake --build ./build --config Release --target "$2" -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
                ;;
            hyprland-qt-support)
                cmake --no-warn-unused-cli -DCMAKE_BUILD_TYPE:STRING=Release -DCMAKE_INSTALL_PREFIX:PATH="$install_prefix" -DINSTALL_QML_PREFIX=/lib/x86_64-linux-gnu/qt6/qml -S . -B ./build
                cmake --build ./build --config Release --target all -j"$(nproc 2>/dev/null || getconf _NPROCESSORS_CONF)"
                ;;
            hyprwayland-scanner)
                cmake -DCMAKE_INSTALL_PREFIX="$install_prefix" -B build
                cmake --build build -j "$(nproc)"
                ;;
            meson)
                meson setup --prefix="$install_prefix" build
                ;;
            esac

            case "$4" in
            cmake)
                sudo cmake --install ./build 2>&1 | tee -a "$MLOG"
                ;;
            meson)
                sudo meson install -C ./build 2>&1 | tee -a "$MLOG"
                ;;
            esac

            if $?; then
                echo "${OK} ${MAGENTA}$2 $release${RESET} installed successfully." 2>&1 | tee -a "$MLOG"
            else
                echo "${ERROR} Installation failed for ${YELLOW}$2 $release${RESET}" 2>&1 | tee -a "$MLOG"
            fi
            if [[ $PEDANTIC_DRY -eq 1 ]]; then
                echo "${NOTE} Not moving $MLOG to $PARENT_DIR/Install-Logs/ with mv"
            else
                #moving the addional logs to Install-Logs directory
                mv "$MLOG" "$PARENT_DIR"/Install-Logs/ || true
            fi
            cd ..
        else
            echo "${ERROR} Download failed for ${YELLOW}$2 $release${RESET}" 2>&1 | tee -a "$LOG"
        fi
    fi

    newlines 2
}
