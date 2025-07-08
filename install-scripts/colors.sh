#!/bin/bash
# shellcheck disable=SC2155

set -a

# Header guard because it is useless to execute the rest of this so many times
[[ -v SOURCED_COLORS ]] && return
SOURCED_COLORS=

# Set some colors for output messages
MAGENTA="$(tput setaf 5)"
YELLOW="$(tput setaf 226)"
RED="$(tput setaf 1)"
ORANGE="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 12)"
GRAY="$(tput setaf 251)"
GREY=$GRAY
WARNING=$ORANGE
RESET="$(tput sgr0)"
OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"
NOTE="${GRAY}[NOTE]${RESET}"
INFO="${BLUE}[INFO]${RESET}"
WARN="${WARNING}[WARN]${RESET}"
CAT="${SKY_BLUE}[ACTION]${RESET}"

set +a
