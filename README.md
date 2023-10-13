
### Debian 13 Trixie- Hyprland install script based from my Fedora-Hyprland [`Link`](https://github.com/JaKooLit/Fedora-Hyprland) and Arch-Hyprland-v4 [`Link`](https://github.com/JaKooLit/Hyprland-v4)

### ⚠️ Pre-requisites:
- Needs a Debian 13 Testing (Trixie) Branch  as it needs a newer wayland packages! I have tried on Stable Debian 12 Bookworm in which, Hyprland wont build
- edit your /etc/apt/sources.list and remove # on lines with deb-src to enable source packaging else will not install properly especially Hyprland
```bash
sudo nano /etc/apt/sources.list
```
- delete # on the lines with 'deb-src' 


### 📷 Screenshots

![alt text](https://github.com/JaKooLit/Debian-Hyprland/blob/main/screenshots/default-dark.png)

![alt text](https://github.com/JaKooLit/Debian-Hyprland/blob/main/screenshots/switching-dark-light.png)

### 📷 Ubuntu 23.10 
![alt text](https://github.com/JaKooLit/Debian-Hyprland/blob/main/screenshots/ubuntu.png)

### 📷 you can find more screenshots in the screenshots directory

### ✨ Youtube presentation [`Link`]() - to be added soon :)

### ✨  Some notes on this installer
- This script is meant to install in Debian Testing (Trixie). 
- If However, decided to try, recommend to install SDDM. Apart from GDM and SDDM, any other Login Manager may not work nor launch Hyprland. However, hyprland can be launched through tty by type Hyprland
- It should work on latest Ubuntu 23.10

### ⚠️ WARNING! nwg-look takes long time to install. 
- nwg-look is a utility to costumize your GTK theme. It's a LXAppearance like. Its a good tool though but this package is entirely optional

### ✨ Costumize the packages 
- inside the install-scripts folder, you can edit 00-hypr-pkgs.sh. Do not edit 00-dependencies.sh unless you know what you are doing
- default GTK theme if agreed to be installed is Tokyo night GTK themes (dark and light) + Tokyo night SE icons

### 🔔 NOTICE TO NVIDIA OWNERS ### 
- by default it is installing the latest and newest nvidia drivers. If you have an older nvidia-gpu (GTX 800 series and older), check out nvidia-debian website [`LINK`](https://wiki.debian.org/NvidiaGraphicsDrivers) and edit nvidia.sh in install-scripts folder to install proper gpu driver

### ✨ to run
> clone this repo by using git. Change directory, make executable and run the script
```bash
git clone https://github.com/JaKooLit/Debian-Hyprland.git
cd Debian-Hyprland
chmod +x install.sh
./install.sh
```
### ✨ for ZSH and OH-MY-ZSH installation
> do this once installed and script completed; do the following to change the default shell zsh
```bash
chsh -s $(which zsh)
zsh
source ~/.zshrc
```
- reboot or logout
- by default mikeh theme is installed. You can find more themes from this [`OH-MY-ZSH-THEMES`](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- to change the theme, edit ~/.zshrc ZSH_THEME="desired theme"

### ✨ Hyprland Dot Notes
- super h for launching a small help file
- super e to view / edit settings, monitor, keybinds, Environment Variables, etc
- go through the keybinds. There are alot of hidden features like dual panel, change waybar styles, change wallpaper, etc... its too long to put all in the readme!!!
- super d for wofi (menu)
- super t for thunar (file manager)

### ✨ Packages that are manually downloaded and build. These packages will not be updated by apt and have to be manually updated
- Hyprland [`LINK`](https://github.com/hyprwm/Hyprland)
- nwg-look [`LINK`](https://github.com/nwg-piotr/nwg-look)
- Asus ROG asusctl [`LINK`](https://gitlab.com/asus-linux/asusctl) and superfxctl [`LINK`](https://gitlab.com/asus-linux/supergfxctl)
- swww [`LINK`](https://github.com/Horus645/swww)
- swaylock-effects [`LINK`](https://github.com/mortie/swaylock-effects)

- a.) to update these package, in your installation folder, you can move these folders, `Hyprland` `nwg-look` `swaylock-effects` `swww` `asusctl` `supergfxctl`, as appropriate or download manually, cd into it, and ran git pull
- b.) for Hyprland, nwg-look, asusctl, supergfxtctl, to update ran `sudo make install`
- c.) for swww, to update `cargo build --release`
- d.) for swaylock-effects 
``` bash
meson build
ninja -C build
sudo ninja -C build install
```

### ✨ Roadmap:
- [ ] Install zsh and oh-my-zsh without necessary steps above
- [ ] possibly adding gruvbox themes, cursors, icons
- [ ] adding vertical waybar 
- [X] ~~Use kitty in favor of foot~~ - Dropped the idea of kitty. Kitty is using twice memory compared to foot.

### ❗ some known issues
- reports from members of my discord, states that some users of nvidia are getting stuck on sddm login. credit  to @Kenni Fix stated was 
```  
 while in sddm press ctrl+alt+F2 or F3
log into your account
`lspci -nn`, find the id of your nvidia card
`ls /dev/dri/by-path` find the matching id
`ls -l /dev/dri/by-path` to check where the symlink points to 
)
7. add "env = WLR_DRM_DEVICES,/dev/dri/cardX" to the ENVvariables config (.config/hypr/configs/ENVariables.conf)  ; X being where the symlink of the gpu points to
```
- more info from the hyprland wiki [`Hyprland Wiki Link`](https://wiki.hyprland.org/FAQ/#my-external-monitor-is-blank--doesnt-render--receives-no-signal-laptop)

- Does not work in Ubuntu 23.04

### 👍 CREDITS

