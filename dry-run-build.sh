#!/usr/bin/env bash
# Dry-run orchestrator for Hyprland and companion modules
# - Compiles components but skips installation (uses DRY_RUN=1)
# - Summarizes PASS/FAIL per module to Install-Logs/
#
# Usage:
#   chmod +x ./dry-run-build.sh
#   ./dry-run-build.sh                  # run full stack dry-run
#   ./dry-run-build.sh --with-deps      # install dependencies first, then dry-run build
#   ./dry-run-build.sh --only hyprland  # run a subset (comma-separated allowed)
#   ./dry-run-build.sh --skip qtutils   # skip one or more (comma-separated)
#
# Notes:
# - Run from the repository root. Do not cd into install-scripts/.
# - You can also call modules directly, e.g., DRY_RUN=1 ./install-scripts/hyprland.sh

set -u
set -o pipefail

REPO_ROOT=$(pwd)
LOG_DIR="$REPO_ROOT/Install-Logs"
mkdir -p "$LOG_DIR"
TS=$(date +%F-%H%M%S)
SUMMARY_LOG="$LOG_DIR/build-dry-run-$TS.log"

# Default module order (core first, then Hyprland)
DEFAULT_MODULES=(
  hyprutils
  hyprlang
  hyprgraphics
  hyprwayland-scanner
  hyprland-protocols
  hyprland-qt-support
  hyprland-qtutils
  aquamarine
  hyprland
)

WITH_DEPS=0
ONLY_LIST=""
SKIP_LIST=""

usage() {
  grep '^# ' "$0" | sed 's/^# \{0,1\}//'
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --with-deps)
      WITH_DEPS=1
      shift
      ;;
    --only)
      ONLY_LIST=${2:-}
      shift 2
      ;;
    --skip)
      SKIP_LIST=${2:-}
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

# Build module list based on --only/--skip
MODULES=()
if [[ -n "$ONLY_LIST" ]]; then
  IFS=',' read -r -a MODULES <<< "$ONLY_LIST"
else
  MODULES=("${DEFAULT_MODULES[@]}")
fi

if [[ -n "$SKIP_LIST" ]]; then
  IFS=',' read -r -a _SKIPS <<< "$SKIP_LIST"
  FILTERED=()
  for m in "${MODULES[@]}"; do
    skip_it=0
    for s in "${_SKIPS[@]}"; do
      if [[ "$m" == "$s" ]]; then
        skip_it=1
        break
      fi
    done
    if [[ $skip_it -eq 0 ]]; then
      FILTERED+=("$m")
    fi
  done
  MODULES=("${FILTERED[@]}")
fi

# Optionally install dependencies (not a dry-run)
if [[ $WITH_DEPS -eq 1 ]]; then
  echo "[INFO] Installing dependencies via 00-dependencies.sh" | tee -a "$SUMMARY_LOG"
  if ! "$REPO_ROOT/install-scripts/00-dependencies.sh"; then
    echo "[ERROR] Dependencies installation failed. See logs under Install-Logs/." | tee -a "$SUMMARY_LOG"
    exit 1
  fi
fi

# Run each module with DRY_RUN=1 and capture exit codes
declare -A RESULTS

echo "[INFO] Starting dry-run build at $TS" | tee -a "$SUMMARY_LOG"

for mod in "${MODULES[@]}"; do
  script_path="$REPO_ROOT/install-scripts/$mod.sh"
  echo "\n=== $mod (DRY RUN) ===" | tee -a "$SUMMARY_LOG"
  if [[ ! -x "$script_path" ]]; then
    # Try to make executable if it exists
    if [[ -f "$script_path" ]]; then
      chmod +x "$script_path" || true
    fi
  fi
  if [[ ! -f "$script_path" ]]; then
    echo "[WARN] Missing script: $script_path" | tee -a "$SUMMARY_LOG"
    RESULTS[$mod]="MISSING"
    continue
  fi
  if DRY_RUN=1 "$script_path"; then
    RESULTS[$mod]="PASS"
  else
    RESULTS[$mod]="FAIL"
  fi
done

# Summary
{
  echo "\nSummary (dry-run):"
  for mod in "${MODULES[@]}"; do
    printf "%-24s %s\n" "$mod" "${RESULTS[$mod]:-SKIPPED}"
  done
  echo "\nLogs: individual module logs are under Install-Logs/. This summary: $SUMMARY_LOG"
} | tee -a "$SUMMARY_LOG"

# Exit non-zero if any FAIL occurred
failed=0
for mod in "${MODULES[@]}"; do
  if [[ "${RESULTS[$mod]:-}" == "FAIL" ]]; then
    failed=1
  fi
done
exit $failed