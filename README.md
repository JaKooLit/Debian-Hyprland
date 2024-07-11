<div align="center">
<br> 
  <a href="#-announcement-"><kbd> <br> Read this First <br> </kbd></a>&ensp;&ensp;
  <a href="#-to-use-this-script"><kbd> <br> How to Use this Script <br> </kbd></a>&ensp;&ensp;
  <a href="#gallery-and-videos"><kbd> <br> Gallery <br> </kbd></a>&ensp;&ensp;
 </div><br>
<div align="center">


## 💌 JaKooLit's Ubuntu Hyprland Install Script 💌
#### For Ubuntu 24.04 Noble Numbat

![GitHub Repo stars](https://img.shields.io/github/stars/JaKooLit/Debian-Hyprland?style=for-the-badge&color=cba6f7) ![GitHub last commit](https://img.shields.io/github/last-commit/JaKooLit/Debian-Hyprland?style=for-the-badge&color=b4befe) ![GitHub repo size](https://img.shields.io/github/repo-size/JaKooLit/Debian-Hyprland?style=for-the-badge&color=cba6f7) <a href="https://discord.gg/9JEgZsfhex"> <img src="https://img.shields.io/discord/1151869464405606400?style=for-the-badge&logo=discord&color=cba6f7&link=https%3A%2F%2Fdiscord.gg%9JEgZsfhex"> </a>

<br/>
</div>

### 🛋️ Why I created a separate branch for Ubuntu 24.04 LTS
- With latest Hyprland v0.40.0 released, it wont build on Ubuntu 24.04 LTS. Reason is that Ubuntu did not update their wayland-protocol. Its the reason why it wont build. 
- This is the reason why I have to set a specific release version on Hyprland packages including its eco-system as it is most likely wayland protocol wont be updated since its an LTS version.

<div align="center">
👇 KOOL's Hyprland-Dots related Links 👇
<br/>
</div>
<div align="center">
<br>
  <a href="https://github.com/JaKooLit/Hyprland-Dots"><kbd> <br> Hyprland-Dots repo <br> </kbd></a>&ensp;&ensp;
  <a href="https://www.youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx"><kbd> <br> Youtube <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki"><kbd> <br> Wiki <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds"><kbd> <br> Keybinds <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ"><kbd> <br> FAQ <br> </kbd></a>&ensp;&ensp;
  <a href="https://discord.gg/9JEgZsfhex"><kbd> <br> Discord <br> </kbd></a>
</div><br>

<h3 align="center">
	<img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
	KooL Hyprland-Dotfiles Showcase 
	<img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
</h3>

<div align="center">

https://github.com/JaKooLit/Hyprland-Dots/assets/85185940/50d53755-0f11-45d6-9913-76039e84a2cd

</div>

> [!IMPORTANT]
> install a backup tool like `snapper` or `timeshift`. and Backup your system before installing hyprland using this script. This script does NOT include uninstallation of packages

> [!NOTE]
> Main reason why I have not included an uninstallation script is simple. Some packages maybe already installed on your system by default. If I create an uninstall script with packages that I have set to install, you may end up a unrecoverable system. 

> [!WARNING] 
> Download this script on a directory where you have write permissions. ie. HOME. Or any directory within your home directory. Else script will fail

#### ⚠️ Pre-requisites and VERY Important! ### 
- Do not run this installer as sudo or as root
- This Installer requires a user with a priviledge to install packages
- This is only tested on 24.04 LTS. Older Ubuntu versions wont work
- If you have login Manager already like GDM (gnome login manager), I highly advice not to install SDDM. But if you decide to install SDDM, see here [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)

> [!IMPORTANT]
> If you are using Gnome already, DO NOT install the SDDM. The GDM Login Manager works well with Hyprland. For some reason, during installation, you will be asked which login manager you wanted to use. But during my test, nothing happened.

> [!WARNING] 
> If you have GDM already as log-in manager, DO NOT install SDDM
> You will encounter issues. See [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)

### Gallery and Videos
<details>
<summary>
📷 Screenshots
</summary>

<p align="center">
    <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Distro-Hyprland/Debian/debian.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Distro-Hyprland/Debian/debian2.png" />       
</p>

<p align="center">
    <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/default-waybar.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Distro-Hyprland/Debian/debian4.png" />   
   <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/wlogout-dark.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Distro-Hyprland/Debian/hyprlock.png"" /> 
   <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/waybar-layout.png" /> <img align="center" width="49%" src="https://raw.githubusercontent.com/JaKooLit/screenshots/main/Hyprland-Dots-Showcase/waybar-style.png"" /> 
</p>

#### ❕ Installed on Kali Linux 😈

![alt text](https://github.com/JaKooLit/screenshots/blob/main/Hyprland-ScreenShots/Debian/Kali-Linux1.png)

#### ❕ Installed on Ubuntu 24.04 LTS with Nvidia Laptop 😷 
![alt text](https://github.com/JaKooLit/screenshots/blob/main/Distro-Hyprland/Ubuntu/Ubuntu-24.04-nvidia.png)


#### 📷 More updated Screenshots Here [`Link`](https://github.com/JaKooLit/screenshots/tree/main/Hyprland-Dots-Showcase)

#### 📷 Older Screenshots: v1[`Link`](https://github.com/JaKooLit/screenshots/tree/main/Hyprland-ScreenShots/Debian) & v2[`Link`](https://github.com/JaKooLit/screenshots/tree/main/Hyprland-ScreenShots/Debian-v2)

</details>

<details>
<summary>
📽️ Youtube Videos
</summary>

#### ✨ Youtube presentation [`V1`](https://youtu.be/hGEWOif5D4Y?si=WQ-PrPwEhM5Og76Q)
#### ✨ Youtube presentation [`V2`](https://youtu.be/Qc4VP9JFh2Y)

#### ✨ A video walk through my dotfiles[`Link`](https://youtu.be/fO-RBHvVEcc?si=ijqxxnq_DLiyO8xb)
#### ✨ A video walk through of My Hyprland-Dots v2[`Link`](https://youtu.be/yaVurRoXc-s?si=iDnBC5S3thPBX3ZE)

#### 💯💯 Check out Installation Video coverage by KSK royal (Ubuntu 23.10 + nvidia)
- [`Link`](https://youtu.be/PMQf9gAt8FE?si=eCBqwXaej-1XXIh_)

#### 💯💯 Check out Installation Video coverage by KSK royal (Kali Linux xfce + nvidia). He have details regarding installing timeshift and switching to sddm from lightdm. He also covers removal of nouveau in favor of proprietary nvidia drivers
- [`Link`](https://youtu.be/NtpRtSBjz3I?si=YGkS75u_7cW5D_zu)

</details>

### 🪧🪧🪧 ANNOUNCEMENT 🪧🪧🪧
- This Repo does not contain Hyprland Dots or configs! Dotfiles can be checked here [`Hyprland-Dots`](https://github.com/JaKooLit/Hyprland-Dots) . During installation, if you opt to copy pre-configured dots, it will be downloaded from that centralized repo.
- Hyprland-Dots use are constantly evolving / improving. you can check CHANGELOGS here [`Hyprland-Dots-Changelogs`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Changelogs)
- Since the Hyprland-Dots are evolving, some of the screenshots maybe old
- the wallpaper offered to be downloaded towards the end is from this [`REPO`](https://github.com/JaKooLit/Wallpaper-Bank)
- The dotfiles that will be pulled by this installer is only specific. Since newer dotfiles might not work properly

> [!NOTE]
> There is a lot of changes on Hyprland v0.40.0. And because of this, the latest Hyprland-Dots compatible for this script will be Hyprland-Dots v2.2.14 [`LINK`](https://github.com/JaKooLit/Hyprland-Dots/releases/tag/v2.2.14)

#### ✨  Some notes on this installer / Prerequisites
- This script is meant to install in Ubuntu 24.04 LTS
- If you are using gnome already, DO NOT install SDDM. GDM will work. Apart from GDM and SDDM, any other Login Manager may not work nor launch Hyprland. However, hyprland can be launched through tty by type Hyprland
- 🕯️ network-manager-gnome (nm-applet) has been removed from the packages to install. This is because it is known to restart the networkmanager causing issues in the installation process. After you boot up, inorder to get the network-manager applet, install network-manager-gnome. `sudo apt install network-manager-gnome` See below if your network or wifi became unmanaged after installation
- If you have nvidia, and wanted to use proprietary drivers, uninstall nouveau first (if installed). This script will be installing proprietary nvidia drivers and will not deal with removal of nouveau.
- NVIDIA users / owners, after installation, check [`THIS`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Notes_to_remember#--for-nvidia-gpu-users)
 
#### ⚠️ WARNING! nwg-look takes long time to install. 
- nwg-look is a utility to costumize your GTK theme. It's a LXAppearance like. Its a good tool though but this package is entirely optional

#### ✨ Costumize the packages to be installed
- inside the install-scripts directory, you can edit 00-hypr-pkgs.sh. Do not edit 00-dependencies.sh unless you know what you are doing. Care though as the Hyprland Dots may not work properly!

#### 💫 SDDM and GTK Themes offered
- If you opted to install SDDM theme, here's the [`LINK`](https://github.com/JaKooLit/simple-sddm)
- If you opted to install GTK Themes, Icons, here's the [`LINK`](https://github.com/JaKooLit/GTK-themes-icons) & Bibata Cursor Modern Ice (assets directory)

#### 🔔 NOTICE TO NVIDIA OWNERS ### 
> [!IMPORTANT]
> If you want to use nouveau driver, choose N when asked if you have nvidia gpu. This is because the nvidia installer part, it will blacklist nouveau. Hyprland will still be installed but it will skip blacklisting nouveau.

## ✨ to use this script
> clone this repo (latest commit only) by using git. Change directory, make executable and run the script
```bash
git clone --depth=1 -b Ubuntu-24.04-LTS https://github.com/JaKooLit/Debian-Hyprland.git ~/Ubuntu-Hyprland
cd ~/Ubuntu-Hyprland
chmod +x install.sh
./install.sh
```
<p align="center">
    <img align="center" width="100%" src="https://github.com/JaKooLit/Debian-Hyprland/blob/Ubuntu-24.04-LTS/Ubuntu24.04.png" />

#### ✨ for ZSH and OH-MY-ZSH installation
> installer should auto change your default shell to zsh. However, if it does not, do this
```bash
chsh -s $(which zsh)
zsh
source ~/.zshrc
```
- reboot or logout
- by default `xiong-chiamiov-plus` theme is installed. You can find more themes from this [`OH-MY-ZSH-THEMES`](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
- to change the theme, edit ~/.zshrc ZSH_THEME="desired theme"

#### ✨ TO DO once installation done and dotfiles copied
- SUPER H for HINT or click on the waybar HINT! Button 
- Head over to [FAQ](https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ) and [TIPS](https://github.com/JaKooLit/Hyprland-Dots/wiki/TIPS)


- if you installed in your laptop and Brightness and Keyboard brightness does not work you can execute this command `sudo chmod +s $(which brightnessctl)`

#### ✨ Packages that are manually downloaded and build. These packages will not be updated by apt and have to be manually updated
- Hyprland [`LINK`](https://github.com/hyprwm/Hyprland)
- nwg-look [`LINK`](https://github.com/nwg-piotr/nwg-look)
- Asus ROG asusctl [`LINK`](https://gitlab.com/asus-linux/asusctl) and superfxctl [`LINK`](https://gitlab.com/asus-linux/supergfxctl)
- swww [`LINK`](https://github.com/Horus645/swww)
- hyprlock [`LINK`](https://github.com/hyprwm/hyprlock)
- hypridle [`LINK`](https://github.com/hyprwm/hypridle)
- hyprlang [`LINK`](https://github.com/hyprwm/hyprlang)
- hyprcursor [`LINK`](https://github.com/hyprwm/hyprcursor)
- swappy [`LINK`](https://github.com/jtheoof/swappy)
- xdg-desktop-portal-hyprland [`LINK`](https://github.com/hyprwm/xdg-desktop-portal-hyprland)
- rofi-wayland [`LINK`](https://github.com/lbonn/rofi)
> [!TIP]
> To update to latest packages, re-running this script will auto update all. Script is configured to pull latest packages build for you.

#### 🤬 FAQ
#### Most common question I got is, Hey Ja, Why the heck it is taking long time to install? Other distro like Arch its only a minute or two. Why here takes like forever?!?!?!
- Well, most of the core packages are downloaded and Build and compiled from SOURCE. There are no pre-built binary (yet) for Debian and Ubuntu. Unlike Other distros, they already have prepacked binary that can just download and install.

> [!NOTE] 
> This script does not setup audio. Kindly set up. If you have not, I recommend pipewire. `sudo apt install -y pipewire`

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

#### ⌨ Keybinds
- Keybinds [`CLICK`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds)

#### 🔧 Proper way to re-installing a particular script from install-scripts directory
- CD into Ubuntu-Hyprland Folder and then ran the below command. 
- i.e. `./install-scripts/gtk-themes.sh` - For reinstall GTK Themes or
- `./install-scripts/sddm.sh` - For reinstall sddm
> [!IMPORTANT]
> DO NOT cd into install-scripts directory as script will most likely to fail

#### 🛣️ Roadmap:
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
- add "env = WLR_DRM_DEVICES,/dev/dri/cardX" to the ENVvariables config `~/.config/hypr/UserConfigs/ENVariables.conf`  ; X being where the symlink of the gpu points to

- more info from the hyprland wiki [`Hyprland Wiki Link`](https://wiki.hyprland.org/FAQ/#my-external-monitor-is-blank--doesnt-render--receives-no-signal-laptop)


- reports from a member of discord for Nvidia for additional env's
- remove # from the following env's on 
```
env = GBM_BACKEND,nvidia-drm
env = WLR_RENDERER_ALLOW_SOFTWARE,1
```

#### ❗ other known issues
> [!NOTE]
> Auto start of Hyprland after login (no SDDM or GDM or any login managers)
- [ ] This was disabled a few days ago. (19 May 2024). This was because some users, after they used the Distro-Hyprland scripts with other DE (gnome-wayland or plasma-wayland), if they choose to login into gnome-wayland for example, Hyprland is starting. 
- [ ] to avoid this, I disabled it. You can re-enable again by editing `~/.zprofile` . Remove all the # on the first lines
- [ ] ROFI issues (scaling, unexplained scaling etc). This is most likely to experience if you are installing on a system where rofi is currently installed. To fix it uninstall rofi and install rofi-wayland . `sudo apt autoremove rofi` . 
- Install rofi-wayland with 
```bash
cd ~/Debian-Hyprland
./install-scripts/rofi-wayland.sh
```
- [ ] Rofi-wayland is compatible with x11 so no need to worry.
- [ ] Does not work in Ubuntu 23.10 and older
- [ ] sddm blackscreen when log-out
- [ ] Installing SDDM if or any other Login Manager installed. See [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)
- [ ] network is down or become unmanaged [`This`](https://askubuntu.com/questions/71159/network-manager-says-device-not-managed) might help
- [ ] pyprland is a hit and miss. Drop down not working, zooming is hit and miss
- [ ] See note above about Hyprland-Dots newer version incompatibility


#### 📒 Final Notes
- join my discord channel [`Discord`](https://discord.com/invite/9JEgZsfhex)
- Feel free to copy, re-distribute, and use this script however you want. Would appreciate if you give me some loves by crediting my work :)


#### ⏩ Contributing
- As stated above, these script does not contain actual config files. These are only the installer of packages
- The development branch of this script is pulling the latest "stable" releases of the Hyprland-Dotfiles.
- If you want to contribute and/or test the Hyprland-Dotfiles (development branch), [`Hyprland-Dots-Development`](https://github.com/JaKooLit/Hyprland-Dots/tree/development) 


#### 👍👍👍 Thanks and Credits!
- [`Hyprland`](https://hyprland.org/) Of course to Hyprland and @vaxerski for this awesome Dynamic Tiling Manager.


### 💖 Support
- a Star on my Github repos would be nice 🌟

- Subscribe to my Youtube Channel [YouTube](https://www.youtube.com/@Ja.KooLit) 

- You can also buy me Coffee Through ko-fi.com or Coffee.com 🤩

<a href='https://ko-fi.com/jakoolit' target='_blank'><img height='35' style='border:0px;height:46px;' src='https://az743702.vo.msecnd.net/cdn/kofi3.png?v=0' border='0' alt='Buy Me a Coffee at ko-fi.com' />

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/JaKooLit)

#### 📹 Youtube videos (Click to view and watch the playlist) 📹
[![Youtube Playlist Thumbnail](https://raw.githubusercontent.com/JaKooLit/screenshots/main/Youtube.png)](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)


                        
## 🥰🥰 💖💖 👍👍👍
[![Stargazers over time](https://starchart.cc/JaKooLit/Debian-Hyprland.svg?variant=adaptive)](https://starchart.cc/JaKooLit/Debian-Hyprland)

                    
