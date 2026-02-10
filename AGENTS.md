# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repo essentials
- Active development happens on the `development` branch; fork or branch from there as documented in `CONTRIBUTING.md`.
- `README.md`, `Debian-Hyprland-Install-Upgrade.md`, and `HOWTO-Install-NVIDIA-drivers-in-Debian.md` explain supported Debian targets (Trixie/SID+), prerequisites (non-root execution, `deb-src`/`non-free` enabled), and NVIDIA caveats—mirror those expectations in new docs.
- Pull requests must use `.github/PULL_REQUEST_TEMPLATE.md` and honor `COMMIT_MESSAGE_GUIDELINES.md`; tests or dry-runs are expected before requesting review.

## Architecture overview
- `install.sh` is the interactive orchestrator: it validates APT sources, enforces non-root execution, loads `hypr-tags.env`, then calls component installers via `execute_script`. Options (GTK themes, NVIDIA, dotfiles, SDDM, etc.) are either selected interactively or injected through `--preset <file>`; TTY-friendly mode is `--tty`.
- `install-scripts/` contains one script per dependency (e.g., `00-dependencies.sh`, `hyprwire.sh`, `hyprland.sh`, `nvidia.sh`). Every script sources `install-scripts/Global_functions.sh`, which defines logging, apt helpers, `BUILD_ROOT`/`SRC_ROOT`, and spinner output. Scripts respect `DRY_RUN=1`, inherit tags such as `HYPRLAND_TAG`, and write detailed logs to `Install-Logs/`.
- `hypr-tags.env` centralizes the Hyprland stack versions. Setting a value to `auto`/`latest` allows tag refreshers to overwrite it; pinned versions stay untouched. These values are exported before every module run.
- `refresh-hypr-tags.sh` and `update-hyprland.sh` manage tag drift and rebuilds without rerunning the full installer. They back up `hypr-tags.env`, fetch GitHub release tags (using `curl`/`jq`), and propagate them to installers.
- `dry-run-build.sh` reuses the same module scripts with `DRY_RUN=1` to compile-only and summarize PASS/FAIL per module—useful for CI or before merging risky changes.
- Root scripts at the top level (`auto-install.sh`, `update-hyprland.sh`, `dry-run-build.sh`, `uninstall.sh`, `preset.sh`) should always be invoked from repo root; per README the module scripts will fail if you `cd install-scripts`.
- `assets/` bundles patches (`0001-fix-hyprland-compile-issue.patch`, `0002-start-hyprland-no-nixgl.patch`), packaged deps (e.g., `libglaze`), and config seeds (zsh themes, GTK/Thunar profiles) consumed by optional installers.

## Key workflows & commands
### Fresh install / rebuild
```bash
git clone --depth=1 -b development https://github.com/JaKooLit/Debian-Hyprland.git ~/Debian-Hyprland
cd ~/Debian-Hyprland
chmod +x install.sh
./install.sh                        # interactive whiptail flow
./install.sh --tty --preset preset.sh  # non-interactive preset run
./install.sh --build-trixie --force-reinstall  # force compatibility shims + apt reinstalls
```
- Run as an unprivileged user; the script escalates with `sudo` as needed. Ensure `deb-src`, `non-free`, and `non-free-firmware` are enabled before starting or let the script fix them when prompted.

### Updating the Hyprland stack only
```bash
./update-hyprland.sh --dry-run --with-deps                  # compile-only sanity check
./update-hyprland.sh --install --with-deps --only hyprland,hyprutils
./update-hyprland.sh --fetch-latest --force-update --install
./update-hyprland.sh --set HYPRLAND=v0.53.4 --dry-run
./update-hyprland.sh --fetch-latest --via-helper --dry-run  # delegates to dry-run-build.sh for summary
```
- Use this script after upgrading Debian releases (e.g., Trixie → Forky) as highlighted in `README.md`. `--with-deps` re-runs `install-scripts/00-dependencies.sh`; `--only/--skip` constrain the module list; `--build-trixie` injects compatibility patches when required.

### Dry-run, testing, and single-module work
```bash
./dry-run-build.sh --with-deps                  # full stack compile test
./dry-run-build.sh --only hyprlang,hyprutils
DRY_RUN=1 ./install-scripts/hyprland.sh         # targeted compile-only run
./install-scripts/hyprwire.sh                   # install a single dependency (from repo root)
```
- All module logs land in `Install-Logs/*.log`; review those when diagnosing failures. For CI, fail the pipeline if any module result is `FAIL` in the dry-run summary.

### Tag maintenance
```bash
./refresh-hypr-tags.sh                   # updates only auto/latest entries
FORCE=1 ./refresh-hypr-tags.sh           # override pinned tags
./refresh-hypr-tags.sh --force-update
cat hypr-tags.env                        # inspect current pins
```
- Keep `hypr-tags.env` under version control—changes should be deliberate and reviewed. `refresh-hypr-tags.sh` and `update-hyprland.sh --fetch-latest` both create `hypr-tags.env.bak-YYYYMMDD-HHMMSS` backups automatically.

## Contribution workflow reminders
- Follow `CONTRIBUTING.md`: branch from `development`, keep PRs focused, and update docs when behavior changes.
- Include dry-run or install logs (`Install-Logs/...`) when fixing installer issues; reviewers expect evidence of successful builds.
- If you touch module ordering or add a new component, update `install.sh` (sequence + option), `update-hyprland.sh` (`DEFAULT_MODULES`), and `dry-run-build.sh` (`DEFAULT_MODULES`) to prevent drift.
- When documenting new options, cross-link the relevant HOWTO/README sections so end users see the guidance surfaces described above.
