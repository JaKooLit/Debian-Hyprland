<div align="center">

## 💌 JaKooLit's Debian/Ubuntu Hyprland Install Script 💌
#### For Debian 13 Trixie and SID and Ubuntu 23.10 Mantic Minotaur or newer

![GitHub Repo stars](https://img.shields.io/github/stars/JaKooLit/Debian-Hyprland?style=for-the-badge&color=cba6f7) ![GitHub last commit](https://img.shields.io/github/last-commit/JaKooLit/Debian-Hyprland?style=for-the-badge&color=b4befe) ![GitHub repo size](https://img.shields.io/github/repo-size/JaKooLit/Debian-Hyprland?style=for-the-badge&color=cba6f7)

<br/>
</div>

### ♨️♨️♨️ ATTENTION ♨️♨️♨️ 06 Dec 2023
- Recent hyprland release v0.33.0, needed a newer libdrm and Debian dont have newer libdrm yet on their repo. That is why for now, the hyprland version to be installed with this script is v0.32.3 

> [!IMPORTANT]
> install a backup tool like `snapper` or `timeshift`. and Backup your system before installing hyprland using this script. This script does NOT include uninstallation of packages

> [!NOTE]
> Main reason why I have not included an uninstallation script is simple. Some packages maybe already installed on your system by default. If I create an uninstall script with packages that I have set to install, you may end up a unrecoverable system. 

#### ⚠️ Pre-requisites and VERY Important! ###
- Do not run this installer as sudo or as root
- This Installer requires a user with a priviledge to install packages
- Needs a Debian 13 Testing (Trixie) Branch  as it needs a newer wayland packages! I have tried on Stable Debian 12 Bookworm in which, Hyprland wont build.
- In theory, it should also work on Debian SID (unstable) but I have not tested yet.
- edit your /etc/apt/sources.list and remove # on lines with deb-src to enable source packaging else will not install properly especially Hyprland
```bash
sudo nano /etc/apt/sources.list
```
- delete # on the lines with 'deb-src' 
- ensure to allow to install non-free drivers especially for users with NVIDIA gpus. You can also install non-free drivers if required. Edit install-scripts/nvidia.sh and change the nvidia stuff's if required
- If you have login Manager already like GDM (gnome login manager), I highly advice not to install SDDM. But if you decide to install SDDM, see here [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)

> [!IMPORTANT]
> UBUNTU USERS: You can use this installer. However, I have only tested on Ubuntu 23.10. Not sure if it works on older ubuntu as Hyprland needs an updated wayland libraries. For sure wont work in any Ubuntu LTS.

> If you are using Gnome already, DO NOT install the SDDM. The GDM works file as well. For some reason, during installation, you will be asked which login manager you wanted to use. But during my test, nothing happened.

> Ubuntu 23.10 dont have cliphist (used as clipboard manager) in their repo yet! And it is not set to build by default. If you want script to install for you, edit `install-scripts/00-hypr-pks.sh` line 15 remove the cliphist under hypr_package . then edit `install.sh` line 175 remove # in `#execute_script "cliphist.sh"`

> [!CAUTION] 
> For Ubuntu with NVIDIA GPU's, make sure to edit the install-scripts/nvidia.sh . Delete all packages in nvidia_pkg except libva-wayland2 and nvidia-vaapi-driver and uncomment/remove # before sudo ubuntu-drivers install. You also need to delete or simply just add # in the lines 37 and 38  echo "echo "## for nvidia" | sudo tee -a... and echo "deb http://deb.debian.org/debian........


> [!WARNING] 
> If you have GDM already as log-in manager, DO NOT install SDDM
> You will encounter issues. See [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)

#### 📷 Hyprland-Dots-v2 Featuring Rofi 
<p align="center">
    <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-ScreenShots/Debian-v2/Debian.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-ScreenShots/Debian-v2/Waybar-Layouts.png" />       
</p>

<p align="center">
    <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/default-waybar.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/rofi.png" />   
   <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/wlogout-dark.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/showcase2.png"" /> 
   <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/waybar-layout.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/waybar-style.png"" /> 
</p>

#### ❕ Installed on Kali Linux 😈

![alt text](https://github.com/JaKooLit/screenshots/blob/main/Hyprland-ScreenShots/Debian/Kali-Linux1.png)

#### 📷 More updated Screenshots Here [`Link`](https://github.com/JaKooLit/screenshots/tree/main/Hyprland-Dots-Showcase)

#### 📷 Older Screenshots: v1[`Link`](https://github.com/JaKooLit/screenshots/tree/main/Hyprland-ScreenShots/Debian) & v2[`Link`](https://github.com/JaKooLit/screenshots/tree/main/Hyprland-ScreenShots/Debian-v2)

#### ✨ Youtube presentation [`V1`](https://youtu.be/hGEWOif5D4Y?si=WQ-PrPwEhM5Og76Q)
#### ✨ Youtube presentation [`V2`](https://youtu.be/Qc4VP9JFh2Y)

#### ✨ A video walk through my dotfiles[`Link`](https://youtu.be/fO-RBHvVEcc?si=ijqxxnq_DLiyO8xb)
#### ✨ A video walk through of My Hyprland-Dots v2[`Link`](https://youtu.be/yaVurRoXc-s?si=iDnBC5S3thPBX3ZE)

#### 💯💯 Check out Installation Video coverage by KSK royal (Ubuntu 23.10 + nvidia)
- [`Link`](https://youtu.be/PMQf9gAt8FE?si=eCBqwXaej-1XXIh_)

#### 💯💯 Check out Installation Video coverage by KSK royal (Kali Linux xfce + nvidia). He have details regarding installing timeshift and switching to sddm from lightdm. He also covers removal of nouveau in favor of proprietary nvidia drivers
- [`Link`](https://youtu.be/NtpRtSBjz3I?si=YGkS75u_7cW5D_zu)

### 🪧🪧🪧 ANNOUNCEMENT 🪧🪧🪧
- This Repo does not contain Hyprland Dots or configs! Dotfiles can be checked here [`Hyprland-Dots`](https://github.com/JaKooLit/Hyprland-Dots) . During installation, if you opt to copy installation, it will be downloaded from that centralized repo.
- Hyprland-Dots use are constantly evolving / improving. you can check CHANGELOGS here [`Hyprland-Dots-Changelogs`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Changelogs)
- Since the Hyprland-Dots are evolving, some of the screenshots maybe old
- the wallpaper offered to be downloaded towards the end is from this [`REPO`](https://github.com/JaKooLit/Wallpaper-Bank)

#### ✨  Some notes on this installer / Prerequisites
- This script is meant to install in Debian Testing (Trixie). 
- If However, decided to try, recommend to install SDDM. Apart from GDM and SDDM, any other Login Manager may not work nor launch Hyprland. However, hyprland can be launched through tty by type Hyprland
- 🕯️ network-manager-gnome (nm-applet) has been removed from the packages to install. This is because it is known to restart the networkmanager causing issues in the installation process. After you boot up, inorder to get the network-manager applet, install network-manager-gnome. `sudo apt install network-manager-gnome` See below if your network or wifi became unmanaged after installation
- If you have nvidia, and wanted to use proprietary drivers, uninstall nouveau first (if installed). This script will be installing proprietary nvidia drivers and will not deal with removal of nouveau.
 
#### ⚠️ WARNING! nwg-look takes long time to install. 
- nwg-look is a utility to costumize your GTK theme. It's a LXAppearance like. Its a good tool though but this package is entirely optional

#### ✨ Costumize the packages to be installed
- inside the install-scripts folder, you can edit 00-hypr-pkgs.sh. Do not edit 00-dependencies.sh unless you know what you are doing. Care though as the Hyprland Dots may not work properly!
- default GTK theme if agreed to be installed is Tokyo night GTK themes (dark and light) + Tokyo night SE icons

#### 💫 SDDM and GTK Themes offered
- If you opted to install SDDM theme, here's the [`LINK`](https://github.com/JaKooLit/simple-sddm)
- If you opted to install GTK Themes, Icons and Cursor offered are Tokyo Nights. [`LINK`](https://github.com/JaKooLit/GTK-themes-icons) & Bibata Cursor Modern Ice 

#### 🔔 NOTICE TO NVIDIA OWNERS ### 
- by default it is installing the latest and newest nvidia drivers. If you have an older nvidia-gpu (GTX 800 series and older), check out nvidia-debian website [`LINK`](https://wiki.debian.org/NvidiaGraphicsDrivers) and edit nvidia.sh in install-scripts folder to install proper gpu driver
> [!IMPORTANT]
> If you want to use nouveau driver, choose N when asked if you have nvidia gpu. This is because the nvidia installer part, it will blacklist nouveau. Hyprland will still be installed but it will skip blacklisting nouveau.

#### ✨ to run
> clone this repo (latest commit only) by using git. Change directory, make executable and run the script
```bash
git clone --depth=1 https://github.com/JaKooLit/Debian-Hyprland.git
cd Debian-Hyprland
chmod +x install.sh
./install.sh
```
<p align="center">
    <img align="center" width="100%" src="https://raw.githubusercontent.com/JaKooLit/Debian-Hyprland/main/Debian-Installer.png" />

#### ✨ for ZSH and OH-MY-ZSH installation
> installer should auto change your default shell to zsh. However, if it does not, do this
```bash
chsh -s $(which zsh)
zsh
source ~/.zshrc
```
- reboot or logout
- by default agnoster theme is installed. You can find more themes from this [`OH-MY-ZSH-THEMES`](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- to change the theme, edit ~/.zshrc ZSH_THEME="desired theme"

#### ✨ TO DO once installation done and dotfiles copied
- ~~if you opted to install gtk themes, to apply the theme and icon, press the dark/light button (beside the padlock). To apply Bibata modern ice cursor, launch nwg-look (GTK Settings) through rofi.~~ Hyprland-Dots v2.1.18, initial boot file will attempt to apply GTK themes,cursor, and icons. You can tweak more using nwg-look (GTK-Settings) utility

- SUPER H for HINT or click on the waybar HINT! Button 
- Head over to [FAQ](https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ) and [TIPS](https://github.com/JaKooLit/Hyprland-Dots/wiki/TIPS)


- if you installed in your laptop and Brightness and Keyboard brightness does not work you can execute this command `sudo chmod +s $(which brightnessctl)`

#### ✨ Packages that are manually downloaded and build. These packages will not be updated by apt and have to be manually updated
- Hyprland [`LINK`](https://github.com/hyprwm/Hyprland)
- nwg-look [`LINK`](https://github.com/nwg-piotr/nwg-look)
- Asus ROG asusctl [`LINK`](https://gitlab.com/asus-linux/asusctl) and superfxctl [`LINK`](https://gitlab.com/asus-linux/supergfxctl)
- swww [`LINK`](https://github.com/Horus645/swww)
- swaylock-effects [`LINK`](https://github.com/mortie/swaylock-effects)
- swappy [`LINK`](https://github.com/jtheoof/swappy)
- xdg-desktop-portal-hyprland [`LINK`](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
- rofi-wayland [`LINK`](https://github.com/lbonn/rofi)
> [!TIP]
> To update to latest packages, re-running this script will auto update all. Script is configured to pull latest packages build for you.

#### 🤬 FAQ
#### Most common question I got is, Hey Ja, Why the heck it is taking long time to install? Other distro like Arch its only a minute or two. Why here takes like forever?!?!?!
- Well, most of the core packages are downloaded and Build and compiled from SOURCE. There are no pre-built binary (yet) for Debian and Ubuntu. Unlike Other distros, they already have prepacked binary that can just download and install.

#### ❗ some known issues on this Installer
- some users reported that they have to install some packages. It is in the install-scripts/force-install.sh
- At this time the packages force to install are the following `imagemagick`

#### 🫥 Improving performance for Older Nvidia Cards using driver 470
  - [`SEE HERE`](https://github.com/JaKooLit/Hyprland-Dots/discussions/123#discussion-6035205)
  
#### 🙋  Got a questions regarding the Hyprland Dots configurations? 🙋
- Head over to wiki Link [`WIKI`](https://github.com/JaKooLit/Hyprland-Dots/wiki)

#### 🙋 👋 Having issues or questions? 
- for the install part, kindly open issue on this repo
- for the Pre-configured Hyprland dots / configuration, submit issue [`here`](https://github.com/JaKooLit/Hyprland-Dots/issues)

#### 🔧 Proper way to re-installing a particular script from install-scripts folder
- CD into Fedora-Hyprland Folder and then ran the below command. 
- i.e. `./install-scripts/gtk-themes` - For reinstall GTK Themes. 

#### 🛣️ Roadmap:
- ~~[ ] Install zsh and oh-my-zsh without necessary steps above~~ DONE 
- [ ] possibly adding gruvbox themes, cursors, icons

#### ❗ some known issues for nvidia
- reports from members of my discord, states that some users of nvidia are getting stuck on sddm login. credit  to @Kenni Fix stated was 
```  
 while in sddm press ctrl+alt+F2 or F3
log into your account
`lspci -nn`, find the id of your nvidia card
`ls /dev/dri/by-path` find the matching id
`ls -l /dev/dri/by-path` to check where the symlink points to 
)
```
- add "env = WLR_DRM_DEVICES,/dev/dri/cardX" to the ENVvariables config (.config/hypr/UserConfigs/ENVariables.conf)  ; X being where the symlink of the gpu points to

- more info from the hyprland wiki [`Hyprland Wiki Link`](https://wiki.hyprland.org/FAQ/#my-external-monitor-is-blank--doesnt-render--receives-no-signal-laptop)


- [ ] Does not work in Ubuntu 23.04
- [ ] sddm blackscreen when log-out
- [ ] Installing SDDM if or any other Login Manager installed. See [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)
- [ ] network is down or become unmanaged [`This`](https://askubuntu.com/questions/71159/network-manager-says-device-not-managed) might help


#### 📒 Final Notes
- join my discord channel [`Discord`](https://discord.gg/V2SJ92vbEN)
- Feel free to copy, re-distribute, and use this script however you want. Would appreciate if you give me some loves by crediting my work :)


#### 👍👍👍 Thanks and Credits!
- [`Hyprland`](https://hyprland.org/) Of course to Hyprland and @vaxerski for this awesome Dynamic Tiling Manager.

#### 💌 Some screenshots shared to me via discord
- Discord user : thunderlake.
![alt text](https://github.com/JaKooLit/Users-screenshots/blob/main/discord/%40thunderlake.png "Discord-user")

### 💖 Support
- a Star on my Github repos would be nice 🌟

- Subscribe to my Youtube Channel [YouTube](https://www.youtube.com/@Ja.KooLit) 

- You can also buy me Coffee Through ko-fi.com or Coffee.com 🤩

<a href='https://ko-fi.com/jakoolit' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/JaKooLit)

#### 📹 Youtube videos (Click to view and watch the playlist) 📹
[![Youtube Playlist Thumbnail](https://raw.githubusercontent.com/JaKooLit/screenshots/main/Youtube.png)](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)