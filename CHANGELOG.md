## CHANGELOG

## 07 February 2026

- Improved `nvidia.sh` script
    - Checks for current kernel headers
    - Improved menu with help
    - `install.sh` checks for deb source and non-free repos
- Improved `install.sh`
    - Removed installing pkgs then build from source later
    - Removed `wayland-protocol` pkg install since we build from source
    - Removed forced re-install of imagick
        - Not sure why that was there but added --force-reinstall flag in case

## 05 February 2026

- Updated `nvidia.sh`
    - Options to install:
        - Debian drivers (older NVIDIA GPUs)
        - For more recent NVIDIA GPUs
            - NVIDIA propriertary drivers
            - NVIDIA open drivers
                - You can switch between them later
    - Read `HOWTO-Install-NVIDIA-Drivers-in-Debian.md`

## 04 February 2026

- Updated Hyprland to current revision
    - AQUAMARINE_TAG=v0.10.0
    - HYPRGRAPHICS_TAG=v0.5.0
    - HYPRLAND_GUIUTILS_TAG=v0.2.1
    - HYPRLAND_PROTOCOLS_TAG=v0.7.0
    - HYPRLAND_QT_SUPPORT_TAG=v0.1.0
    - HYPRLAND_QTUTILS_TAG=v0.1.5
    - HYPRLAND_TAG=v0.53.3
    - HYPRLANG_TAG=v0.6.8
    - HYPRTOOLKIT_TAG=v0.5.3
    - HYPRUTILS_TAG=v0.11.0
    - HYPRWAYLAND_SCANNER_TAG=v0.4.5
    - HYPRWIRE_TAG=v0.3.0
    - WAYLAND_PROTOCOLS_TAG=1.46
- Updated `uninstall.sh` to remove source built binaries
- Fixed build issues with Debian Trixie
- Fixed installation path handling
- Removed old code related to debian packages for Hyprland

## 27 January 2026

### Fixed build issue with Debian stable (trixie)

- All references to `Nix::`, `Nix.hpp`, `Nix.cpp`, `--no-nixgl`, and `nixGL` in the built Hyprland sources are removed via assets/0002-start-hyprland-no-nixgl.patch.
- The patch:
    - Drops the Nix include and logic from `start/src/core/Instance.cpp`, `start/src/core/State.hpp`, and `start/src/main.cpp`.
    - Removes the `--no-nixgl` flag and the Nix environment checks.
    - Now `start-hyprland` starts `Hyprland` directly, with no `nixGL` wrapper or Nix environment inspection.

## 24 January 2026

- Updated Hyprland version to v0.53.3
- Fixes `hyprpm` issues
- All other packages remain at the same version

## 23 January 2026

- New layout for building Hyprland Source
    - The `build` directory will hold the source and compiler output
    - Now you can just remove the build directory after install
- Updated the default Hyprland version to `v0.53.2`
- Updated the documentation on the new directory layout
- Fixed issue of Fastfetch reading old hyprland version file

## 21 January 2026

### Important Note for Debian `Trixie` users.

- If you later upgrade Debian to `Forky` or `SID` you **MUST** recompile Hyprland!!
    - Run `update-hyprland --install --with-deps`
    - Reboot after
    - Failure to do so will prevent Hyprland from starting
    - You will be returned to the login manager

## 15 January 2026

- Updated README
    - Added not about not supporting `Kali` Linux
    - Update info on NVIDIA GPUs
    - Cleaning up some formatting

## 02 January 2026

### > Note: Support for Hyprland v0.53.2 is now available for Debian Stable (Trixie)

### > At this time it should be considered BETA, not for production use

### > Testing with NVIDIA has not yet been done

### > Only Intel, AMD, and in VMs

- Updated:
    - Default Hyprland stack versions now target 0.53.2 (see `hypr-tags.env`)
    - Added trixie compatibility mode flags:
        - `--build-trixie` / `--no-trixie` (auto-detected on Debian 13)
    - Added `--force-update` to refresh pinned package versions
    - `update-hyprland.sh` added `-/--help`
    - Documentation for updating hyprland
- Added:
    - Version refresh improvements for `refresh-hypr-tags.sh` (accepts `--get-latest`, retries transient GitHub errors)
- Fixed:
    - `--force-update` implies `--fetch-latest`

## 10 December 2025

- Updated:
    - Hyprland Build to v0.52.2
    - Thanks entirely to @sdegler
- Fixed:
    - `qt5-style-kvantum-themes` failed to install
        - Wrong package name it's `qt-style-kvantume-themes`
    - `libdisplay-info2` failed to install
        - New package name: `libdisplay-info3`

## 10 October 2025

### Hyprland 0.51.x install support

-     Hyprland builds 0.51.x from source
-     Added documentation for upgrading from 0.49/0.50.x to 0.51.1.

### New scripts and modules

    - update-hyprland.sh: Manage the Hyprland stack with:
      - --install / --dry-run build modes
      - --only and --skip for selective components
      - --with-deps to (re)install build deps
      - --set {KEY=TAG} and --restore tag backup support
      - --fetch-latest to pull latest GitHub release tags
      - --via-helper to delegate summary-only dry-runs
    - dry-run-build.sh: Compile-only helper with summary output
    - install-scripts/wayland-protocols-src.sh: Build wayland-protocols from
      source (>= 1.45) to satisfy Hyprland 0.51.x requirements

### Core features

    - Centralized tag management via hypr-tags.env; tags exported to all
      modules. Environment overrides remain first priority.
    - Automatic dependency ordering for Hyprland 0.51.x:
      wayland-protocols-src → hyprland-protocols → hyprutils → hyprlang →
      aquamarine → hyprland
    - Optional auto-fetch of latest tags on install runs that include
      hyprland (can be disabled via --no-fetch)
    - Selective updates for targeted components and skip lists
    - Dry-run mode to validate builds without installing

### Installer integration

    - install.sh reads hypr-tags.env and optionally refreshes tags.
    - Ensures wayland-protocols-src is built before Hyprland.
    - Maintains proper sequencing for the Hyprland dependencies.

### Docs

    - Debian-Hyprland-Install-Upgrade.md and .es.md:
      - Add explicit section: Upgrade 0.49/0.50.x → 0.51.1
      - Recommend: `./update-hyprland.sh --install --only hyprland`
      - Provide optional `--with-deps` and `--dry-run` flows
    - Full install via install.sh is not required for this
      upgrade unless optional modules need refresh

### Usage highlights

    - Pin and upgrade to 0.51.1:
      ./update-hyprland.sh --set HYPRLAND=v0.51.1
      ./update-hyprland.sh --install --only hyprland
    - Optional:
      ./update-hyprland.sh --with-deps --install --only hyprland
      ./update-hyprland.sh --dry-run --only hyprland

### Notes

    - Target OS remains Debian Trixie/Testing/SID
    - Run as sudo-capable user (not root)
    - Ensure deb-src entries are enabled.

## 22 July 2025

- Updated sddm theme and script to work with the updated simple_sddm_2 theme
- Manual building process

## 21 June 2025

- Added a warning message that support is now very limited

## 08 June 2025

- updated SDDM theme.

## 20 March 2025

- added findutils as dependencies

## 11 March 2025

- Added uninstall script
- forked AGS v1 into JakooLit repo. This is just incase Aylur decide to take down v1

## 10 March 2025

- Dropped pyprland in favor of hyprland built in tool for a drop down like terminal and Desktop magnifier

## 06 March 2025

- Switched to whiptail version for Y & N questions
- switched eza to lsd

## 23 Feb 2025

- added Victor Mono Font for proper hyprlock font rendering for Dots v2.3.12
- added Fantasque Sans Mono Nerd for Kitty

## 22 Feb 2025

- replaced eog with loupe
- changed url for installing oh-my-zsh to get wider coverage. Some countries are blocking github raw url's

## 18 Feb 2025

- Change default zsh theme to adnosterzak
- pokemon coloscript integrated with fastfetch when opted with pokemon to add some bling
- additional external oh-my-zsh theme

## 06 Feb 2025

- added semi-unattended function.
- move all the initial questions at the beginning

## 04 Feb 2025

- Re-coded for better visibility
- Offered a new SDDM theme.
- script will automatically detect if you have nvidia but script still offer if you want to set up for user

## 30 Jan 2025

- AGS (aylur's GTK shell) v1 for desktop overview is now optional

## 12 Jan 2025

- switch to final version of aylurs-gtk-shell-v1

## 01 Jan 2025

- Switched to download dots from KooL's Hyprland dots specific branch

## 26 Dec 2024

- Removal of Bibata Ice cursor on assets since its integrated in the GTK Themes and Icons extract from a separate repo

## 10 Dec 2024

- updated swww.sh to download from version v0.9.5

## 24 Nov 2024

- switched to download rofi-wayland from releases instead from upstream

## 20 Sep 2024

- User will be ask if they want to set Thunar as default file manager if they decided to install it

## 19 Sep 2024

- updated xdph installation since it is now in Debian Repo
- Added fastfetch on tty. However, will be disabled if user decided to install pokemon colorscripts

## 14 Sep 2024

- Added Essential Packages final check in lieu of errors from Install log files in Install-Logs directory
- nwg-look is now in Debian Repo

## 10 Sep 2024

- added background check of known login managers if they are active if user chose to install sddm

## 08 Sep 2024

- Added final error checks on install-logs

## 07 Sep 2024

- Fix installation issue on hyprlock and xdph
- disabled imagemagick compilation from source
- dotfiles adjusted so it will be compatible for imagemagick v6

## 04 Sep 2024

- added a function to check if it is Ubuntu or Based on Ubuntu and script will exit

## 28 Aug 2024

- Added final check if hyprland is installed and will give an error to user

## 24 Aug 2024

- Created a newer and compatible Hyprland-Dots repo
-

## 23 Aug 2024

- Moved Ubuntu-Hyprland on a separate Github Repo

## 22 Aug 2024

- refactor Debian-Hyprland script. As Hyprland is now in official repo

## 07 Jul 2024

- added eza (ls replacement for tty). Note only on .zshrc

## 06 July 2024

- Version bumps for Debian (Hyprland v0.41.2)

## 11 June 2024

- adjusted script to install only Hyprland-Dots v2.2.14

## 10 June 2024

- changed behaviour of rofi-wayland.sh. To redownload a new rofi-wayland from repo instead of pulling changes. (It proves giving issue)

## 04 June 2024

- switched over to source install for imagemagick
- removal of fzf for Debian and Ubuntu (headache)

## 26 May 2024

- Added fzf for zsh (CTRL R to invoke FZF history)

## 23 May 2024

- added qalculate-gtk to work with rofi-calc. Default keybinds (SUPER ALT C)
- added power-profiles-daemon for ROG laptops. Note, I cant add to all since it conflicts with TLP, CPU-Auto-frequency etc.
- Note: Fastfetch configs will be added from Hyprland-Dots v2.2.12. However, you need to install from Fastfetch github page

## 19 May 2024

- Disabled the auto-login in .zprofile as it causes auto-login to Hyprland if any wayland was chosen. Can enabled if only using hyprland

## 15 May 2025

- Backed down hyprland version to install as v0.40.0 is failing to install
- removed from waybar-git to install. Instead to install from official repo
- cliphist install script is removed as it is now on Debian repo
- dependencies cleaned up and added

## 10 May 2024

- added wallust-git and remove python-pywal for migration to wallust on Hyprland-Dots v2.2.11

## 07 May 2024

- added ags.sh for upcoming ags overview for next Hyprland-Dots release. Will be installed form source
- added manual installation of waybar since Debian is very slow in updating their packages

## 03 May 2024

- Bump swww to v0.9.5
- added python3-pyquery for new weather-waybar python based on Hyprland-Dots

## 02 May 2024

- Added pyprland (hyprland plugin) - warning, I cant make it to properly run. Drop Down terminal not working, zoom is hit and miss

## 30 Apr 2024

- Updated hyprland.sh to install v0.39.1 Hyprland
- adding hypridle and hyprlock
- dropping swaylock-effects and swayidle
- adjusted to work with current Hyprland-Dots

## 22 Apr 2024

- Change dotfiles to specific version only as Debian and Ubuntu cant keep up with Hyprland development

## 20 Apr 2024

- Change default Oh-my-zsh theme to xiong-chiamiov-plus

## 11 Jan 2024

- dropped wlsunset
- added hyprlang build and install

## 02 Jan 2024

- Readme updated for cliphist instruction for ubuntu 23.10 users
- Created cliphist.sh for ubuntu 23.10 users (disabled by default and needs to be enabled on install.sh if desired)

## 30 December 2023

- Code Cleaned up.
- Pokemon Color Scripts now offered as optional

## 29 December 2023

- Remove dunst in favor of swaync. NOTE: Part of the script is to also uninstall mako and dunst (if installed) as on my experience, dunst is sometimes taking over the notification even if it is not set to start

## 16 Dec 2023

- zsh theme switched to `agnoster` theme by default
- pywal tty color change disabled by default

## 13 Dec 2023

- Added a script / function to force install packages. Some users reported that it is not installed.

## 11 Dec 2023

- Changing over to zsh automatically if user opted
- If chose to install zsh and have no login manager, zsh auto login will auto start Hyprland
- added as optional, with zsh, pokemon colorscripts
- improved zsh install scripts, so even the existing zsh users of can still opt for zsh and oh-my-zsh installation :)

## 03 Dec 2023

- Added kvantum for qt apps theming
- return of wlogout due to theming issues of rofi-power

## 1 Dec 2023

- replace the Hyprland to specific branch/version as newest needed some new libraries and debian dont have those yet

## 26 Nov 2023

- nvidia - Move to normal hyprland package as nvidia patches are doing nothing see [`commit`](https://github.com/hyprwm/Hyprland/commit/cd96ceecc551c25631783499bd92c6662c5d3616)

## 25 Nov 2023

- drop wlogout since Hyprland-Dots v2.1.9 uses rofi-power

## 23-Nov-2023

- Added Bibata cursor to install if opted for GTK Themes. However, it is not pre-applied. Use nwg-look utility to apply

## 19-Nov-2023

- Adjust dotfiles script to download from releases instead of from upstream

## 14-Oct-2023

- initial release. Added swappy for screenshots

## 12-Oct-2023

- BETA release
