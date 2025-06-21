## CHANGELOGS

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
