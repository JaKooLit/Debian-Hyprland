#!/bin/bash
# Helper file for parsing arguments, exposing only the parse_args function and important argument variables
# Argument parsing is for install.sh though

set -aeuo pipefail
IFS=$'\n\t'

# Header guard since this should be executed only once
[[ -v SOURCED_PARSE_ARGS ]] && return
SOURCED_PARSE_ARGS=

SCRIPT_DIR=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

source "$SCRIPT_DIR/colors.sh" || {
    echo "Failed to source colors.sh"
    exit 1
}

# Define main argument variables

if [[ ! -v VERBOSE ]]; then
    VERBOSE=0
    DRY=0
    DRY_RUN_DIR_SET=0
    DRY_RUN_DIR=""
    PEDANTIC_DRY=0
    NO_BUILD=0
    PRESET=""
    PRESET_ENABLED=0
    PURGE=0
fi

# Parse arguments by passing "$@" to this for ./install.sh
parse_args() {
    # Are there no arguments? If so, this is a useless function
    if [[ $# -eq 0 ]]; then return; fi

    # Define argument parsing options
    LONGOPTS=help,verbose,dry-run,dry-run-dir:,pedantic-dry-run,no-build,preset:
    SHORTOPTS=hvd:p:

    # Print help message
    print_help() {
        echo "Usage: $0 [-hv] [-d DRY_RUN_DIR] [-p PRESET] [--dry-run] [--dry-run-dir DRY_RUN_DIR] [--pedantic-dry-run] [--help] [--verbose]"
        echo "[--preset PRESET]"
        echo "Run the install script for KooL's automated install of Hyprland for Debian Trixie/Sid."
        echo
        echo "${WARNING}Please be sure to backup your system before running this script as it will"
        echo "FORCIBLY INSTALL AND REMOVE packages WITHOUT user intervention.${RESET}"
        echo "PLEASE NOTE: Run this script from the directory this script is in."
        echo
        echo "  -h, --help          display this help message and exit successfully"
        echo "  -v, --verbose       be loud and verbose; output many debugging messages"
        echo
        echo "The following section is intended for developers:"
        echo "Additionally, they are designed to try not to modify files outside this script's directory."
        echo "  --dry-run                          do a dry run by installing to a test dir, specified with"
        echo "the --dry-run-dir option; aka don't possibly break your system. Do note, apt packages will be"
        echo "installed for this script, but the Install-Logs directory will not be created if nonexistent."
        echo "  -d, --dry-run-dir=DRY_RUN_DIR      specify directory to do the dry run installation into;"
        echo "defaults to this script's directory's faux-install-dir directory, which will be"
        echo "automatically created. Specify DRY_RUN_DIR to install there instead, but you have to create the"
        echo "directory yourself. Can only be used when using the --dry-run option"
        echo "  --pedantic-dry-run                 absolutely do not install apt packages, so assuming you have"
        echo "them all. Also do not synchronize package index files with sudo apt update. Attempts to not modify"
        echo "any file except for building. Overrides --dry-run"
        echo "option, and the same rules for --dry-run-dir or -d applies."
        echo "  --no-build                         don't build anything from source. Can only be used with either"
        echo "the --dry-run/-d or --pedantic-dry-run options. This will probably cause the script to fail."
        echo
        echo
        echo "  -p, --preset=PRESET                specify preset file, which can be, for example, preset.sh in"
        echo "the Debian-Hyprland directory. See that preset.sh file for details."
        echo "  --purge                            When removing packages, purge (delete all configuration files)"
        echo "them. Dangerous if you want to keep them. This also purges autoremoved packages."
        echo
        echo "Hint: You do not have to specify the whole argument name as getopt tries to fill the rest in, unless"
        echo "what was entered is ambiguous. Example: --pedantic-dr is synonymous with --pedantic-dry-run."
        echo
        echo "View repository and complain about bugs to: <https://github.com/JaKooLit/Debian-Hyprland/>"
    }

    # Function to test if GNU's enhanced getopt works
    parse_args_setup() {
        ENHANCED_GETOPT=1

        # Temporarily disable Bash from exiting if command has error
        set +e
        # Test if GNU's enhanced getopt exists
        getopt --test 2>/dev/null
        if [[ $? -ne 4 ]]; then
            echo "${GRAY}I require GNU's enhanced getopt to parse arguments."
            echo "You can continue without parsing arguments or install util-linux,"
            echo "which should have been installed on Debian.${RESET}"
            ENHANCED_GETOPT=0
        fi
        # Back to being strict
        set -e

        if [[ "$ENHANCED_GETOPT" == 0 ]]; then
            read -rp "Would you like to continue without parsing arguments? [y/N]: " confirm
            case "$confirm" in
            [yY][eE][sS] | [yY])
                echo "${OK} Ignoring arguments and continuing installation..."
                ;;
            *)
                echo "${NOTE} You chose not to continue. Exiting..."
                exit 1
                ;;
            esac
        fi
    }

    # Specfically check for help and verbose argument first to allow verbosity for everything even if option is not in order
    parse_first_args() {
        if [[ "$ENHANCED_GETOPT" == 1 ]]; then
            if ! PARSED=$(getopt --options "${SHORTOPTS}" --longoptions "${LONGOPTS}" --name "$0" -- "$@"); then
                echo "${ERROR} Failed to use getopt to parse arguments! Exiting with atypical error code 2..."
                exit 2
            fi

            eval set -- "${PARSED}"

            while [[ $# -gt 0 ]]; do
                case $1 in
                -h | --help)
                    print_help
                    exit 0
                    ;;
                -v | --verbose)
                    VERBOSE=1
                    echo "${CAT} Enabled verbose mode."
                    ;;
                esac
                shift
            done
        fi
    }

    # Check validity and saneness of arguments
    check_sane_arguments() {
        if [[ $DRY -eq 1 && $PEDANTIC_DRY -eq 1 ]]; then
            echo "${INFO} --pedantic-dry-run overrides the --dry-run option, so also enabling dry run mode."
            DRY=1
        fi

        # When dry and pedantic dry are both disabled
        if [[ $DRY -eq 0 && $PEDANTIC_DRY -eq 0 ]]; then
            if [[ $DRY_RUN_DIR_SET -eq 1 ]]; then
                echo "${WARN} Ignoring --dry-run-dir option as the --dry-run or --pedantic-dry-run option is not enabled."
                DRY_RUN_DIR_SET=0
            elif [[ $NO_BUILD -eq 1 ]]; then
                echo "${WARN} Ignoring --no-build option as the --dry-run or --pedantic-dry-run option is not enabled."
                NO_BUILD=0
            fi
        fi

        if [[ $DRY -eq 1 && $DRY_RUN_DIR_SET -eq 0 ]]; then
            echo "${WARN} Using ${WORKING_DIR}/faux-install-dir since --dry-run-dir was not set."
            DRY_RUN_DIR="$WORKING_DIR"/faux-install-dir
            verbose_log "DRY_RUN_DIR is now ${DRY_RUN_DIR}"
        fi

        # If DRY_RUN_DIR_SET is 1, which means --dry-run-dir or -d was passed as an argument, and DRY_RUN_DIR is not a directory
        if [[ $DRY_RUN_DIR_SET -eq 1 && (! -d "$DRY_RUN_DIR") ]]; then
            echo "${ERROR} --dry-run-dir option set to $DRY_RUN_DIR is not a valid directory. Exiting..."
            exit 1
        fi

        # If PRESET_ENABLED is 1, which means --preset or -p was passed as an argument, and PRESET is a file that does not exist
        if [[ $PRESET_ENABLED -eq 1 ]]; then
            if [[ ! -f "$PRESET" ]]; then
                PRESET_ENABLED=0
                echo "${WARN} ⚠️ Preset file not found or invalid: $PRESET. Using default values."
            else
                PRESET_ENABLED=1
                verbose_log "PRESET_ENABLED set to 1 as PRESET, $PRESET, is a file that exists."
            fi
        else
            verbose_log "Not using preset since --preset was not specified"
        fi

        if [[ $DRY -eq 1 && $PURGE -eq 1 ]]; then
            echo "${WARN} Purge mode will not have any real effect with dry or pedantic dry mode."
        fi
    }

    parse_args_setup

    # Time to handle arguments (or not if system does not support GNU's enhanced getopt or no arguments were passed)
    if [[ $ENHANCED_GETOPT -eq 1 ]]; then
        parse_first_args "$@"

        if ! PARSED=$(getopt --options "${SHORTOPTS}" --longoptions "${LONGOPTS}" --name "$0" -- "$@"); then
            echo "${ERROR} Failed to use getopt to parse arguments! Exiting with atypical error code 2..."
            exit 2
        fi
        verbose_log "Parsed with getopt: $PARSED"

        eval set -- "${PARSED}"

        while [[ $# -gt 0 ]]; do
            verbose_log "Met argument $1"
            case $1 in
            -h | --help)
                # Already handled in parse_first_args local function, so this is a noop for reference
                ;;
            -v | --verbose)
                # Already handled in parse_first_args local function, so this is a noop for reference
                ;;
            --dry-run)
                DRY=1
                verbose_log "Using dry run mode (does not install to system but to custom directory)"
                ;;
            -d | --dry-run-dir)
                shift 1
                DRY_RUN_DIR_SET=1
                DRY_RUN_DIR="$(realpath "$1")"
                verbose_log "Setting DRY_RUN_DIR to $(realpath "$1")"
                ;;
            --pedantic-dry-run)
                PEDANTIC_DRY=1
                echo "${NOTE} Using pedantic dry run mode, which will ${RED}NOT${RESET} install any packages but only build from source, even if you are missing apt packages. Use the --help or -h option for more info."
                ;;
            --no-build)
                NO_BUILD=1
                echo "${NOTE} Using no build mode, which ${RED}DISABLES${RESET} building anything from source."
                ;;
            -p | --preset)
                shift 1
                PRESET_ENABLED=1
                PRESET="$(realpath "$1")"
                verbose_log "Setting PRESET to $(realpath "$1")"
                ;;
            --purge)
                shift 1
                PURGE=1
                verbose_log
                ;;
            --)
                # For some reason, this option is always present when using getopt, so this is a noop
                ;;
            *)
                echo "${WARN} Ignoring positional argument: $1"
                ;;
            esac
            shift # Move to next argument
        done

        check_sane_arguments
    fi
    # End of arguments complaining and shenanigans with https://gist.github.com/mcnesium/bbfe60e4f43554cbc2880f2e7085956d used for help
}
set +a
