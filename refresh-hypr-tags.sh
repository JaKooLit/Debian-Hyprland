#!/usr/bin/env bash
# Refresh hypr-tags.env with latest release tags from upstream
# Safe to run multiple times; creates timestamped backups

set -euo pipefail

REPO_ROOT=$(pwd)
TAGS_FILE="$REPO_ROOT/hypr-tags.env"
LOG_DIR="$REPO_ROOT/Install-Logs"
mkdir -p "$LOG_DIR"
TS=$(date +%F-%H%M%S)
SUMMARY_LOG="$LOG_DIR/refresh-tags-$TS.log"

usage() {
  cat <<'EOF'
refresh-hypr-tags.sh
Refresh hypr-tags.env with latest GitHub release tags.

Usage:
  ./refresh-hypr-tags.sh
  FORCE=1 ./refresh-hypr-tags.sh
  ./refresh-hypr-tags.sh --force-update
  ./refresh-hypr-tags.sh --get-latest

Notes:
  - By default, only updates keys set to auto/latest (or unset).
  - Use FORCE=1 or --force-update to override pinned values.
EOF
}

# Arg parsing (minimal/backwards compatible)
FORCE=${FORCE:-0}
for arg in "$@"; do
  case "$arg" in
    -h|--help)
      usage
      exit 0
      ;;
    --force-update|--force)
      FORCE=1
      ;;
    # Alias for user ergonomics; refresh always checks latest tags.
    --get-latest|--fetch-latest)
      :
      ;;
    *)
      echo "[WARN] Unknown argument ignored: $arg" | tee -a "$SUMMARY_LOG"
      ;;
  esac
done

# Ensure tags file exists
if [[ ! -f "$TAGS_FILE" ]]; then
cat > "$TAGS_FILE" <<'EOF'
# Default Hyprland stack versions
HYPRLAND_TAG=v0.53.3
AQUAMARINE_TAG=v0.10.0
HYPRUTILS_TAG=v0.11.0
HYPRLANG_TAG=v0.6.8
HYPRGRAPHICS_TAG=v0.5.0
HYPRTOOLKIT_TAG=v0.4.1
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.7.0
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.5
HYPRLAND_GUIUTILS_TAG=v0.2.0
HYPRWIRE_TAG=v0.2.1
WAYLAND_PROTOCOLS_TAG=1.46
EOF
fi

# Backup
cp "$TAGS_FILE" "$TAGS_FILE.bak-$TS"
echo "[INFO] Backed up $TAGS_FILE to $TAGS_FILE.bak-$TS" | tee -a "$SUMMARY_LOG"

if ! command -v curl >/dev/null 2>&1; then
  echo "[ERROR] curl is required to refresh tags" | tee -a "$SUMMARY_LOG"
  exit 1
fi

# Map of env var -> repo
# (Some modules may not publish GitHub releases; in that case the tag may not refresh.)
declare -A repos=(
  [HYPRLAND_TAG]="hyprwm/Hyprland"
  [AQUAMARINE_TAG]="hyprwm/aquamarine"
  [HYPRUTILS_TAG]="hyprwm/hyprutils"
  [HYPRLANG_TAG]="hyprwm/hyprlang"
  [HYPRGRAPHICS_TAG]="hyprwm/hyprgraphics"
  [HYPRTOOLKIT_TAG]="hyprwm/hyprtoolkit"
  [HYPRWAYLAND_SCANNER_TAG]="hyprwm/hyprwayland-scanner"
  [HYPRLAND_PROTOCOLS_TAG]="hyprwm/hyprland-protocols"
  [HYPRLAND_QT_SUPPORT_TAG]="hyprwm/hyprland-qt-support"
  [HYPRLAND_QTUTILS_TAG]="hyprwm/hyprland-qtutils"
  [HYPRLAND_GUIUTILS_TAG]="hyprwm/hyprland-guiutils"
  [HYPRWIRE_TAG]="hyprwm/hyprwire"
  [HYPRWIRE_PROTOCOLS_TAG]="hyprwm/hyprwire-protocols"
  # Additional apps/utilities
  [HYPRIDLE_TAG]="hyprwm/hypridle"
  [HYPRLOCK_TAG]="hyprwm/hyprlock"
  [HYPRPICKER_TAG]="hyprwm/hyprpicker"
  [HYPRSHUTDOWN_TAG]="hyprwm/hyprshutdown"
  [HYPRPWCENTER_TAG]="hyprwm/hyprpwcenter"
  [HYPRTAVERN_TAG]="hyprwm/hyprtavern"
  [HYPRSUNSET_TAG]="hyprwm/hyprsunset"
  [HYPRLAUNCHER_TAG]="hyprwm/hyprlauncher"
  [HYPRSYSTEMINFO_TAG]="hyprwm/hyprsysteminfo"
)

# Read existing
declare -A cur
while IFS='=' read -r k v; do
  [[ -z "${k:-}" || "$k" =~ ^# ]] && continue
  cur[$k]="$v"
done < "$TAGS_FILE"

# Fetch latest, but only update keys set to 'auto' or 'latest' unless forced
changes=()
for key in "${!repos[@]}"; do
  repo="${repos[$key]}"
  url="https://api.github.com/repos/$repo/releases/latest"
  echo "[INFO] Checking latest tag for $repo" | tee -a "$SUMMARY_LOG"

  # Be resilient to transient GitHub API errors (e.g. 5xx).
  body=$(curl -fsSL \
    --retry 3 --retry-all-errors --retry-delay 1 \
    -H 'Accept: application/vnd.github+json' \
    "$url" || true)

  [[ -z "$body" ]] && { echo "[WARN] Empty response for $repo" | tee -a "$SUMMARY_LOG"; continue; }
  if command -v jq >/dev/null 2>&1; then
    tag=$(printf '%s' "$body" | jq -r '.tag_name // empty')
  else
    tag=$(printf '%s' "$body" | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name"\s*:\s*"([^"]+)".*/\1/')
  fi
  if [[ -z "$tag" ]]; then
    echo "[WARN] Could not parse tag for $repo" | tee -a "$SUMMARY_LOG"
    continue
  fi
  existing="${cur[$key]:-}"
  if [[ $FORCE -eq 1 ]] || [[ "$existing" =~ ^(auto|latest)$ ]] || [[ -z "$existing" ]]; then
    cur[$key]="$tag"
    if [[ "$existing" != "$tag" ]]; then
      changes+=("$key: $existing -> $tag")
    fi
    echo "[OK] $key := $tag" | tee -a "$SUMMARY_LOG"
  else
    echo "[SKIP] $key pinned ($existing), not overriding" | tee -a "$SUMMARY_LOG"
  fi
done

# Show change summary and prompt before writing (interactive only)
if [[ -t 0 && ${#changes[@]} -gt 0 ]]; then
  printf "\nPlanned tag updates (refresh-hypr-tags.sh):\n" | tee -a "$SUMMARY_LOG"
  printf "%s\n" "${changes[@]}" | tee -a "$SUMMARY_LOG"
  printf "\nProceed with writing updated tags to %s? [Y/n]: " "$TAGS_FILE"
  read -r ans || true
  ans=${ans:-Y}
  case "$ans" in
    [nN]|[nN][oO])
      echo "[INFO] User aborted tag update; leaving $TAGS_FILE unchanged." | tee -a "$SUMMARY_LOG"
      exit 0
      ;;
  esac
fi

# Write back
{
  for k in "${!cur[@]}"; do
    echo "$k=${cur[$k]}"
  done | sort
} > "$TAGS_FILE"

echo "[OK] Refreshed tags written to $TAGS_FILE" | tee -a "$SUMMARY_LOG"
