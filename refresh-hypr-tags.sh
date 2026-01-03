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

# Ensure tags file exists
if [[ ! -f "$TAGS_FILE" ]]; then
cat > "$TAGS_FILE" <<'EOF'
HYPRLAND_TAG=v0.51.1
AQUAMARINE_TAG=v0.9.3
HYPRUTILS_TAG=v0.8.2
HYPRLANG_TAG=v0.6.4
HYPRGRAPHICS_TAG=v0.1.5
HYPRWAYLAND_SCANNER_TAG=v0.4.5
HYPRLAND_PROTOCOLS_TAG=v0.6.4
HYPRLAND_QT_SUPPORT_TAG=v0.1.0
HYPRLAND_QTUTILS_TAG=v0.1.4
HYPRWIRE_TAG=auto
WAYLAND_PROTOCOLS_TAG=1.45
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

# Read existing
declare -A cur
while IFS='=' read -r k v; do
  [[ -z "${k:-}" || "$k" =~ ^# ]] && continue
  cur[$k]="$v"
  # keep original snapshot for diff
  orig_${k}="$v"
  export orig_${k} 2>/dev/null || true
done < "$TAGS_FILE"

# Fetch latest, but only update keys set to 'auto' or 'latest' unless forced
FORCE=${FORCE:-0}
changes=()
for key in "${!repos[@]}"; do
  repo="${repos[$key]}"
  url="https://api.github.com/repos/$repo/releases/latest"
  echo "[INFO] Checking latest tag for $repo" | tee -a "$SUMMARY_LOG"
  body=$(curl -fsSL "$url" || true)
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
