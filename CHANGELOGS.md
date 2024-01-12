## Changelogs

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
