#!/usr/bin/env bash
# update-hyprland.sh
# Manage and build just the Hyprland stack (Hyprland + companion apps/libs)
# - Maintains a central tag file (hypr-tags.env) with versions
# - Can fetch latest release tags from GitHub and update hypr-tags.env
# - Can restore tags from a backup
# - Can run a dry-run build (compile only) or install build of the stack
#
# Usage examples:
#   chmod +x ./update-hyprland.sh
#   ./update-hyprland.sh --dry-run                 # compile-only using current tags
#   ./update-hyprland.sh --install                 # compile + install using current tags
#   ./update-hyprland.sh --fetch-latest --dry-run  # refresh tags to latest, then dry-run
#   ./update-hyprland.sh --set HYPRLAND=v0.51.1 --dry-run  # set one or more tags
#   ./update-hyprland.sh --restore --dry-run       # restore most recent backup of tags and dry-run
#   ./update-hyprland.sh --only hyprland,hyprutils --dry-run
#   ./update-hyprland.sh --skip aquamarine --install
#   ./update-hyprland.sh --with-deps --dry-run
#   ./update-hyprland.sh --fetch-latest --via-helper   # use dry-run-build.sh for a summary-only run
#   ./update-hyprland.sh --force-update --install      # override pinned versions (equivalent to FORCE=1)
#   ./update-hyprland.sh --help                        # show this help
#
# Notes:
# - Requires curl; for --fetch-latest, jq is recommended (installed by 00-dependencies.sh)
# - Works from repo root; do not cd into install-scripts/

set -euo pipefail

REPO_ROOT=$(pwd)
TAGS_FILE="$REPO_ROOT/hypr-tags.env"
LOG_DIR="$REPO_ROOT/Install-Logs"
mkdir -p "$LOG_DIR"
TS=$(date +%F-%H%M%S)
SUMMARY_LOG="$LOG_DIR/update-hypr-$TS.log"

# Default module order (core first, then Hyprland)
DEFAULT_MODULES=(
    xkbcommon
    hyprutils
    hyprlang
    hyprtoolkit
    wayland-protocols-src
    aquamarine
    hyprgraphics
    hyprwayland-scanner
    hyprland-protocols
    hyprland-qt-support
    hyprland-guiutils
    hyprwire
    hyprland
)

WITH_DEPS=0
DO_INSTALL=0
DO_DRY_RUN=0
FETCH_LATEST=0
RESTORE=0
VIA_HELPER=0
NO_FETCH=0
USE_SYSTEM_LIBS=1
AUTO_FALLBACK=0
MINIMAL=0
FORCE_UPDATE=0
ONLY_LIST=""
SKIP_LIST=""
SET_ARGS=()

usage() {
    # Print the header comments (quick reference) followed by explicit flags overview
    sed -n '2,140p' "$0" | sed -n '/^# /p' | sed 's/^# \{0,1\}//'
    cat <<EOF

Options:
  -h, --help            Show this help and exit
      --with-deps       Install build dependencies before running
      --dry-run         Compile only; do not install
      --install         Compile and install
      --fetch-latest    Fetch latest releases from GitHub
      --force-update    Override pinned values in hypr-tags.env (equivalent to FORCE=1)
      --restore         Restore most recent hypr-tags.env backup
      --only LIST       Comma-separated subset to build (e.g., hyprland,hyprutils)
      --skip LIST       Comma-separated modules to skip
      --bundled         Build Hyprland with bundled hypr* subprojects
      --system          Prefer system-installed hypr* libraries (default)
      --via-helper      Use dry-run-build.sh to summarize a dry-run
      --minimal         Build minimal stack before hyprland
      --no-fetch        Do not auto-fetch tags on install
      --set K=V [...]   Set one or more tags (e.g., HYPRLAND=v0.53.0)
EOF
}

ensure_tags_file() {
    if [[ ! -f "$TAGS_FILE" ]]; then
        echo "[INFO] Creating default tags file: $TAGS_FILE" | tee -a "$SUMMARY_LOG"
        cat >"$TAGS_FILE" <<'EOF'
HYPRLAND_TAG=v0.50.1
AQUAMARINE_TAG=v0.9.2
HYPRUTILS_TAG=v0.8.2
HYPRLANG_TAG=v0.6.4
HYPRGRAPHICS_TAG=v0.1.5
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.6.4
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.4
HYPRWIRE_TAG=auto
EOF
    fi
}

backup_tags() {
    ensure_tags_file
    cp "$TAGS_FILE" "$TAGS_FILE.bak-$TS"
    echo "[INFO] Backed up $TAGS_FILE to $TAGS_FILE.bak-$TS" | tee -a "$SUMMARY_LOG"
}

restore_tags() {
    latest_bak=$(ls -1t "$TAGS_FILE".bak-* 2>/dev/null | head -n1 || true)
    if [[ -z "$latest_bak" ]]; then
        echo "[ERROR] No backup tags file found." | tee -a "$SUMMARY_LOG"
        exit 1
    fi
    cp "$latest_bak" "$TAGS_FILE"
    echo "[INFO] Restored tags from $latest_bak" | tee -a "$SUMMARY_LOG"
}

set_tags_from_args() {
    ensure_tags_file
    backup_tags
    # load existing into assoc map
    declare -A map
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        map[$k]="$v"
    done <"$TAGS_FILE"
    for kv in "${SET_ARGS[@]}"; do
        key="${kv%%=*}"
        val="${kv#*=}"
        case "$key" in
        HYPRLAND | hyprland) key=HYPRLAND_TAG ;;
        AQUAMARINE | aquamarine) key=AQUAMARINE_TAG ;;
        HYPRUTILS | hyprutils) key=HYPRUTILS_TAG ;;
        HYPRLANG | hyprlang) key=HYPRLANG_TAG ;;
        HYPRGRAPHICS | hyprgraphics) key=HYPRGRAPHICS_TAG ;;
        HYPRWAYLAND_SCANNER | hyprwayland-scanner | hyprwayland_scanner) key=HYPRWAYLAND_SCANNER_TAG ;;
        HYPRLAND_PROTOCOLS | hyprland-protocols | hyprland_protocols) key=HYPRLAND_PROTOCOLS_TAG ;;
        HYPRLAND_QT_SUPPORT | hyprland-qt-support | hyprland_qt_support) key=HYPRLAND_QT_SUPPORT_TAG ;;
        HYPRLAND_QTUTILS | hyprland-qtutils | hyprland_qtutils) key=HYPRLAND_QTUTILS_TAG ;;
        esac
        map[$key]="$val"
    done
    {
        for k in "${!map[@]}"; do
            echo "$k=${map[$k]}"
        done | sort
    } >"$TAGS_FILE"
    echo "[INFO] Updated $TAGS_FILE with provided tags" | tee -a "$SUMMARY_LOG"
}

# Fetch latest release tags from GitHub for the stack
fetch_latest_tags() {
    ensure_tags_file
    backup_tags
    CHANGES_FILE="$LOG_DIR/update-delta-$TS.log"
    : >"$CHANGES_FILE"

    # Require curl; jq is preferred. Fallback to grep/sed if jq is missing.
    if ! command -v curl >/dev/null 2>&1; then
        echo "[ERROR] curl is required." | tee -a "$SUMMARY_LOG"
        exit 1
    fi

    # Read existing to respect pinned values (only update keys set to 'auto' or 'latest')
    declare -A existing
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        existing[$k]="$v"
    done <"$TAGS_FILE"

    declare -A repos=(
        [HYPRLAND_TAG]="hyprwm/Hyprland"
        [AQUAMARINE_TAG]="hyprwm/aquamarine"
        [HYPRUTILS_TAG]="hyprwm/hyprutils"
        [HYPRLANG_TAG]="hyprwm/hyprlang"
        [HYPRGRAPHICS_TAG]="hyprwm/hyprgraphics"
        [HYPRWAYLAND_SCANNER_TAG]="hyprwm/hyprwayland-scanner"
        [HYPRLAND_PROTOCOLS_TAG]="hyprwm/hyprland-protocols"
        [HYPRLAND_QT_SUPPORT_TAG]="hyprwm/hyprland-qt-support"
        [HYPRLAND_QTUTILS_TAG]="hyprwm/hyprland-qtutils"
        [HYPRWIRE_TAG]="hyprwm/hyprwire"
    )

    declare -A tags

    for key in "${!repos[@]}"; do
        repo="${repos[$key]}"
        url="https://api.github.com/repos/$repo/releases/latest"
        echo "[INFO] Fetching latest tag for $repo" | tee -a "$SUMMARY_LOG"
        body=$(curl -fsSL "$url" || true)
        if [[ -z "$body" ]]; then
            echo "[WARN] Empty response for $repo; leaving $key unchanged" | tee -a "$SUMMARY_LOG"
            continue
        fi
        if command -v jq >/dev/null 2>&1; then
            tag=$(printf '%s' "$body" | jq -r '.tag_name // empty')
        else
            tag=$(printf '%s' "$body" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name"\s*:\s*"([^"]+)".*/\1/')
        fi
        if [[ -n "$tag" ]]; then
            tags[$key]="$tag"
        else
            echo "[WARN] Could not parse tag for $repo; leaving $key unchanged" | tee -a "$SUMMARY_LOG"
        fi
    done

    # Merge into existing file
    declare -A map
    while IFS='=' read -r k v; do
        [[ -z "$k" || "$k" =~ ^# ]] && continue
        map[$k]="$v"
    done <"$TAGS_FILE"

    # Build a list of changes (old -> new) according to override rules
    changes=()
    for k in "${!tags[@]}"; do
        if [[ $FORCE_UPDATE -eq 1 ]]; then
            # Force override regardless of current value (matches FORCE=1 behavior in refresh-hypr-tags.sh)
            map[$k]="${tags[$k]}"
        else
            # Only override if pinned value is 'auto' or 'latest' (or unset)
            if [[ "${existing[$k]:-}" =~ ^(auto|latest)$ ]] || [[ -z "${existing[$k]:-}" ]]; then
                map[$k]="${tags[$k]}"
            fi
        fi
    done

    # Interactive confirmation before writing, if we have a TTY
    if [[ -t 0 && ${#changes[@]} -gt 0 ]]; then
        printf "\nPlanned tag updates (update-hyprland.sh):\n" | tee -a "$SUMMARY_LOG"
        printf "%s\n" "${changes[@]}" | tee -a "$SUMMARY_LOG" | tee -a "$CHANGES_FILE"
        printf "\nProceed with writing updated tags to %s? [Y/n]: " "$TAGS_FILE"
        read -r ans || true
        ans=${ans:-Y}
        case "$ans" in
            [nN]|[nN][oO])
                echo "[INFO] User aborted tag update; leaving $TAGS_FILE unchanged." | tee -a "$SUMMARY_LOG"
                # restore original copy
                latest_bak=$(ls -1t "$TAGS_FILE".bak-* 2>/dev/null | head -n1 || true)
                [[ -n "$latest_bak" ]] && cp "$latest_bak" "$TAGS_FILE"
                return 0
                ;;
        esac
    else
        # non-interactive: still record changes
        printf "%s\n" "${changes[@]}" >>"$CHANGES_FILE" || true
    fi

    {
        for k in "${!map[@]}"; do
            echo "$k=${map[$k]}"
        done | sort
    } >"$TAGS_FILE"

    echo "[INFO] Refreshed tags written to $TAGS_FILE" | tee -a "$SUMMARY_LOG"
}

# Build runner using module scripts. Uses env vars from TAGS_FILE.
run_stack() {
    # shellcheck disable=SC1090
    source "$TAGS_FILE"
    # Export all tag keys found in the tags file so child scripts inherit them
    while IFS='=' read -r _k _v; do
        [[ -z "${_k:-}" || "$_k" =~ ^# ]] && continue
        # Only export keys that look like TAG variables or protocol version
        if [[ "$_k" == *"_TAG" || "$_k" == "WAYLAND_PROTOCOLS_TAG" ]]; then
            export "$_k"
        fi
    done < "$TAGS_FILE"

    # Ensure toolchain paths prefer /usr/local for pkg-config and cmake finds
    export PATH="/usr/local/bin:${PATH}"
    export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:${PKG_CONFIG_PATH:-}"
    export CMAKE_PREFIX_PATH="/usr/local:${CMAKE_PREFIX_PATH:-}"

    # Propagate system/bundled selection to hyprland.sh
    if [[ $USE_SYSTEM_LIBS -eq 1 ]]; then
        export USE_SYSTEM_HYPRLIBS=1
    else
        export USE_SYSTEM_HYPRLIBS=0
    fi

    # Optionally install dependencies (not dry-run)
    if [[ $WITH_DEPS -eq 1 ]]; then
        echo "[INFO] Installing dependencies via 00-dependencies.sh" | tee -a "$SUMMARY_LOG"
        if ! "$REPO_ROOT/install-scripts/00-dependencies.sh"; then
            echo "[ERROR] Dependencies installation failed." | tee -a "$SUMMARY_LOG"
            exit 1
        fi
    fi

    # Build module list based on --only/--skip
    local modules
    if [[ -n "$ONLY_LIST" ]]; then
        IFS=',' read -r -a modules <<<"$ONLY_LIST"
    else
        if [[ $MINIMAL -eq 1 ]]; then
            modules=(
                wayland-protocols-src
                hyprland-protocols
                hyprutils
                hyprlang
                aquamarine
                hyprgraphics
                hyprwayland-scanner
                hyprwire
                hyprland
            )
        else
            modules=("${DEFAULT_MODULES[@]}")
        fi
    fi
    if [[ -n "$SKIP_LIST" ]]; then
        IFS=',' read -r -a _skips <<<"$SKIP_LIST"
        local filtered=()
        for m in "${modules[@]}"; do
            local skip_it=0
            for s in "${_skips[@]}"; do
                [[ "$m" == "$s" ]] && {
                    skip_it=1
                    break
                }
            done
            [[ $skip_it -eq 0 ]] && filtered+=("$m")
        done
        modules=("${filtered[@]}")
    fi

    # Ensure core prerequisites are installed before hyprland on install runs
    # Order: wayland-protocols-src, hyprland-protocols, hyprutils, hyprlang, aquamarine, hyprland
    if [[ $DO_INSTALL -eq 1 ]]; then
        # Auto-fetch latest tags for Hyprland stack unless disabled
        if [[ $NO_FETCH -eq 0 ]]; then
            # Detect whether hyprland is part of the run
            need_fetch=0
            for m in "${modules[@]}"; do
                [[ "$m" == "hyprland" ]] && need_fetch=1
            done
            if [[ $need_fetch -eq 1 ]]; then
                echo "[INFO] Auto-fetching latest tags for Hyprland stack" | tee -a "$SUMMARY_LOG"
                fetch_latest_tags
            fi
        fi
        local has_hl=0 has_aqua=0 has_wp=0 has_utils=0 has_lang=0 has_hlprot=0
        for m in "${modules[@]}"; do
            [[ "$m" == "hyprland" ]] && has_hl=1
            [[ "$m" == "aquamarine" ]] && has_aqua=1
            [[ "$m" == "wayland-protocols-src" ]] && has_wp=1
            [[ "$m" == "hyprland-protocols" ]] && has_hlprot=1
            [[ "$m" == "hyprutils" ]] && has_utils=1
            [[ "$m" == "hyprlang" ]] && has_lang=1
        done
        if [[ $has_hl -eq 1 ]]; then
            # When using system libs, ensure required libs will be built if missing/outdated
            if [[ $USE_SYSTEM_LIBS -eq 1 ]]; then
                if ! pkg-config --exists hyprwire 2>/dev/null; then
                    modules=("hyprwire" "${modules[@]}")
                fi
                req_utils_ver="0.11.0"
                have_utils_ver=$(pkg-config --modversion hyprutils 2>/dev/null || echo "")
                if [[ -z "$have_utils_ver" ]] || [[ "$(printf '%s\n' "$req_utils_ver" "$have_utils_ver" | sort -V | head -n1)" != "$req_utils_ver" ]]; then
                    modules=("hyprutils" "${modules[@]}")
                fi
                if ! pkg-config --exists hyprlang 2>/dev/null; then
                    modules=("hyprlang" "${modules[@]}")
                fi
            fi
            # ensure each prerequisite is present
            [[ $has_wp -eq 0 ]] && modules=("wayland-protocols-src" "${modules[@]}")
            [[ $has_hlprot -eq 0 ]] && modules=("hyprland-protocols" "${modules[@]}")
            [[ $has_utils -eq 0 ]] && modules=("hyprutils" "${modules[@]}")
            [[ $has_lang -eq 0 ]] && modules=("hyprlang" "${modules[@]}")
            [[ $has_aqua -eq 0 ]] && modules=("aquamarine" "${modules[@]}")

            # Reorder to exact sequence before hyprland
            # Remove existing occurrences and rebuild in correct order
            local tmp=()
            local inserted_wp=0 inserted_hlprot=0 inserted_utils=0 inserted_lang=0 inserted_aqua=0
            for m in "${modules[@]}"; do
                if [[ "$m" == "wayland-protocols-src" ]]; then
                    if [[ $inserted_wp -eq 0 ]]; then
                        tmp+=("wayland-protocols-src")
                        inserted_wp=1
                    fi
                elif [[ "$m" == "hyprland-protocols" ]]; then
                    if [[ $inserted_hlprot -eq 0 ]]; then
                        # ensure wayland-protocols-src before hyprland-protocols
                        if [[ $inserted_wp -eq 0 ]]; then
                            tmp+=("wayland-protocols-src")
                            inserted_wp=1
                        fi
                        tmp+=("hyprland-protocols")
                        inserted_hlprot=1
                    fi
                elif [[ "$m" == "hyprutils" ]]; then
                    if [[ $inserted_utils -eq 0 ]]; then
                        # ensure protocols before utils
                        if [[ $inserted_wp -eq 0 ]]; then
                            tmp+=("wayland-protocols-src")
                            inserted_wp=1
                        fi
                        if [[ $inserted_hlprot -eq 0 ]]; then
                            tmp+=("hyprland-protocols")
                            inserted_hlprot=1
                        fi
                        tmp+=("hyprutils")
                        inserted_utils=1
                    fi
                elif [[ "$m" == "hyprlang" ]]; then
                    if [[ $inserted_lang -eq 0 ]]; then
                        # ensure utils before lang
                        if [[ $inserted_utils -eq 0 ]]; then
                            if [[ $inserted_wp -eq 0 ]]; then
                                tmp+=("wayland-protocols-src")
                                inserted_wp=1
                            fi
                            if [[ $inserted_hlprot -eq 0 ]]; then
                                tmp+=("hyprland-protocols")
                                inserted_hlprot=1
                            fi
                            tmp+=("hyprutils")
                            inserted_utils=1
                        fi
                        tmp+=("hyprlang")
                        inserted_lang=1
                    fi
                elif [[ "$m" == "aquamarine" ]]; then
                    if [[ $inserted_aqua -eq 0 ]]; then
                        # ensure lang before aquamarine
                        if [[ $inserted_lang -eq 0 ]]; then
                            if [[ $inserted_utils -eq 0 ]]; then
                                if [[ $inserted_wp -eq 0 ]]; then
                                    tmp+=("wayland-protocols-src")
                                    inserted_wp=1
                                fi
                                if [[ $inserted_hlprot -eq 0 ]]; then
                                    tmp+=("hyprland-protocols")
                                    inserted_hlprot=1
                                fi
                                tmp+=("hyprutils")
                                inserted_utils=1
                            fi
                            tmp+=("hyprlang")
                            inserted_lang=1
                        fi
                        tmp+=("aquamarine")
                        inserted_aqua=1
                    fi
                elif [[ "$m" == "hyprland" ]]; then
                    # ensure all prerequisites already present
                    if [[ $inserted_wp -eq 0 ]]; then
                        tmp+=("wayland-protocols-src")
                        inserted_wp=1
                    fi
                    if [[ $inserted_hlprot -eq 0 ]]; then
                        tmp+=("hyprland-protocols")
                        inserted_hlprot=1
                    fi
                    if [[ $inserted_utils -eq 0 ]]; then
                        tmp+=("hyprutils")
                        inserted_utils=1
                    fi
                    if [[ $inserted_lang -eq 0 ]]; then
                        tmp+=("hyprlang")
                        inserted_lang=1
                    fi
                    if [[ $inserted_aqua -eq 0 ]]; then
                        tmp+=("aquamarine")
                        inserted_aqua=1
                    fi
                    tmp+=("hyprland")
                else
                    tmp+=("$m")
                fi
            done
            modules=("${tmp[@]}")
        fi
    fi

    declare -A results

    for mod in "${modules[@]}"; do
        local script="$REPO_ROOT/install-scripts/$mod.sh"
        echo "\n=== $mod ===" | tee -a "$SUMMARY_LOG"
        [[ -f "$script" ]] || {
            echo "[WARN] Missing $script" | tee -a "$SUMMARY_LOG"
            results[$mod]="MISSING"
            continue
        }
        chmod +x "$script" || true
        if [[ $DO_DRY_RUN -eq 1 ]]; then
            if DRY_RUN=1 "$script"; then results[$mod]="PASS"; else results[$mod]="FAIL"; fi
        else
            if "$script"; then results[$mod]="INSTALLED"; else results[$mod]="FAIL"; fi
        fi
    done

    {
        printf "\nSummary:\n"
        for mod in "${modules[@]}"; do
            printf "%-24s %s\n" "$mod" "${results[$mod]:-SKIPPED}"
        done
        # Show updated versions (final tag values)
        if [[ -f "$TAGS_FILE" ]]; then
            printf "\nUpdated versions (from %s):\n" "$TAGS_FILE"
            grep -E '^[A-Z0-9_]+=' "$TAGS_FILE" | sort
        fi
        # Include change list if present
        if [[ -f "$LOG_DIR/update-delta-$TS.log" ]]; then
            printf "\nChanges applied this run:\n"
            cat "$LOG_DIR/update-delta-$TS.log"
        fi
        printf "\nLogs under: %s. This run: %s\n" "$LOG_DIR" "$SUMMARY_LOG"
    } | tee -a "$SUMMARY_LOG"

    # Non-zero on any FAILs
    local failed=0
    for mod in "${modules[@]}"; do
        [[ "${results[$mod]:-}" == FAIL ]] && failed=1
    done
    return $failed
}

# Parse args
while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
        usage
        exit 0
        ;;
    --with-deps)
        WITH_DEPS=1
        shift
        ;;
    --dry-run)
        DO_DRY_RUN=1
        shift
        ;;
    --install)
        DO_INSTALL=1
        shift
        ;;
    --fetch-latest)
        FETCH_LATEST=1
        shift
        ;;
    --force-update)
        FORCE_UPDATE=1
        shift
        ;;
    --restore)
        RESTORE=1
        shift
        ;;
    --via-helper)
        VIA_HELPER=1
        shift
        ;;
    --no-fetch)
        NO_FETCH=1
        shift
        ;;
    --only)
        ONLY_LIST=${2:-}
        shift 2
        ;;
    --bundled)
        USE_SYSTEM_LIBS=0
        shift
        ;;
    --system)
        USE_SYSTEM_LIBS=1
        shift
        ;;
    --auto)
        AUTO_FALLBACK=1
        shift
        ;;
    --minimal)
        MINIMAL=1
        shift
        ;;
    --skip)
        SKIP_LIST=${2:-}
        shift 2
        ;;
    --set)
        shift
        while [[ $# -gt 0 && "$1" != --* ]]; do
            SET_ARGS+=("$1")
            shift
        done
        ;;
    *)
        echo "Unknown argument: $1"
        exit 2
        ;;
    esac
done

# Validate options
if [[ $DO_INSTALL -eq 1 && $DO_DRY_RUN -eq 1 ]]; then
    echo "[ERROR] Use either --dry-run or --install, not both." | tee -a "$SUMMARY_LOG"
    exit 2
fi

ensure_tags_file

# Env compatibility: honor FORCE=1 as alias for --force-update
if [[ ${FORCE:-0} -eq 1 ]]; then
    FORCE_UPDATE=1
fi

# Apply tag operations
if [[ $RESTORE -eq 1 ]]; then
    restore_tags
fi
if [[ ${#SET_ARGS[@]} -gt 0 ]]; then
    set_tags_from_args
fi
if [[ $FETCH_LATEST -eq 1 ]]; then
    fetch_latest_tags
fi

# Run the stack
if [[ $DO_DRY_RUN -eq 0 && $DO_INSTALL -eq 0 ]]; then
    echo "[INFO] No build option specified. Defaulting to --dry-run." | tee -a "$SUMMARY_LOG"
    DO_DRY_RUN=1
fi

# If using helper, delegate to dry-run-build.sh for summary-only output
if [[ $VIA_HELPER -eq 1 ]]; then
    if [[ $DO_INSTALL -eq 1 ]]; then
        echo "[ERROR] --via-helper cannot be combined with --install (helper is dry-run only)." | tee -a "$SUMMARY_LOG"
        exit 2
    fi
    # shellcheck disable=SC1090
    source "$TAGS_FILE"
    # Export all tag variables dynamically
    while IFS='=' read -r _k _v; do
        [[ -z "${_k:-}" || "$_k" =~ ^# ]] && continue
        if [[ "$_k" == *"_TAG" || "$_k" == "WAYLAND_PROTOCOLS_TAG" ]]; then
            export "$_k"
        fi
    done < "$TAGS_FILE"
    helper="$REPO_ROOT/dry-run-build.sh"
    if [[ ! -x "$helper" ]]; then
        echo "[ERROR] dry-run-build.sh not found or not executable at $helper" | tee -a "$SUMMARY_LOG"
        exit 1
    fi
    args=()
    [[ $WITH_DEPS -eq 1 ]] && args+=("--with-deps")
    [[ -n "$ONLY_LIST" ]] && args+=("--only" "$ONLY_LIST")
    [[ -n "$SKIP_LIST" ]] && args+=("--skip" "$SKIP_LIST")
    echo "[INFO] Delegating to dry-run-build.sh ${args[*]}" | tee -a "$SUMMARY_LOG"
    "$helper" "${args[@]}"
    exit $?
fi

if run_stack; then
    exit 0
else
    rc=$?
    if [[ $AUTO_FALLBACK -eq 1 && $USE_SYSTEM_LIBS -eq 1 ]]; then
        echo "[WARN] Build failed with system libs. Retrying with bundled subprojects..." | tee -a "$SUMMARY_LOG"
        USE_SYSTEM_LIBS=0
        if run_stack; then
            exit 0
        else
            exit $?
        fi
    else
        exit $rc
    fi
fi
