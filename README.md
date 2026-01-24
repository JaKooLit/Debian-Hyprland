<div align="center">

# 💌 KooL's Debian-Hyprland Install Script 💌

#### For Debian 13 (Trixie) and above (testing, SID)

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="400" />
</p>

![GitHub Repo stars](https://img.shields.io/github/stars/JaKooLit/Debian-Hyprland?style=for-the-badge&color=cba6f7) ![GitHub last commit](https://img.shields.io/github/last-commit/JaKooLit/Debian-Hyprland?style=for-the-badge&color=b4befe) ![GitHub repo size](https://img.shields.io/github/repo-size/JaKooLit/Debian-Hyprland?style=for-the-badge&color=cba6f7) <a href="https://discord.gg/kool-tech-world"> <img src="https://img.shields.io/discord/1151869464405606400?style=for-the-badge&logo=discord&color=cba6f7&link=https%3A%2F%2Fdiscord.gg%kool-tech-world"> </a>

<br/>
</div>

## IMPORTANT note for Debian `Trixie` users

> If you later update Debian to `Forky` or `SID` you **MUST** recompile Hyprland!!
> Run `update-hyprland.sh --install --with-deps`
> Reboot afterwards
> Failure to do so will prevent Hyprland from starting under `Forky` or `SID`
> It will return to the login manager

<div align="center">
<br>
  <a href="#-announcement-"><kbd> <br> Read this First <br> </kbd></a>&ensp;&ensp;
  <a href="#-to-use-this-script"><kbd> <br> Installation <br> </kbd></a>&ensp;&ensp;
  <a href="#gallery-and-videos"><kbd> <br> Gallery <br> </kbd></a>&ensp;&ensp;
 </div><br>

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="200" />
</p>

<div align="center">
👇 KOOL's Hyprland-Dots related Links 👇
<br/>
</div>
<div align="center">
<br>
  <a href="https://github.com/JaKooLit/Hyprland-Dots/tree/Debian-Dots"><kbd> <br> Hyprland-Dots Debian repo <br> </kbd></a>&ensp;&ensp;
  <a href="https://www.youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx"><kbd> <br> Youtube <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki"><kbd> <br> Wiki <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds"><kbd> <br> Keybinds <br> </kbd></a>&ensp;&ensp;
  <a href="https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ"><kbd> <br> FAQ <br> </kbd></a>&ensp;&ensp;
  <a href="https://discord.gg/RZJgC7KAKm"><kbd> <br> Discord <br> </kbd></a>
</div><br>

<p align="center">
  <img src="https://raw.githubusercontent.com/JaKooLit/Hyprland-Dots/main/assets/latte.png" width="200" />
</p>

<h3 align="center">
 <img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
 KooL Hyprland-Dotfiles Showcase
 <img src="https://github.com/JaKooLit/Telegram-Animated-Emojis/blob/main/Activity/Sparkles.webp" alt="Sparkles" width="38" height="38" />
</h3>

<div align="center">

<https://github.com/user-attachments/assets/49bc12b2-abaf-45de-a21c-67aacd9bb872>

</div>

### Gallery and Videos

#### 🎥 Feb 2025 Video explanation of installation with preset

- [YOUTUBE-LINK](https://youtu.be/wQ70lo7P6vA?si=_QcbrNKh_Bg0L3wC)
- [YOUTUBE-Hyprland-Playlist](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)
- [AGS overview DEMO](https://youtu.be/zY5SLNPBJTs)

> [!IMPORTANT]
> install a backup tool like `snapper` or `timeshift`. and Backup your system before installing hyprland using this script (**HIGHLY RECOMMENDED**).

> [!CAUTION]
> Download this script on a directory where you have write permissions. ie. HOME. Or any directory within your home directory. Else script will fail

#### ⚠️ Pre-requisites and VERY Important

> Note: At this time `Kali` Linux is not supported.
> A number of users have reported issues installing and using the Dotfiles

- Do not run this installer with `sudo` or as `root`
- This Installer requires a user with a `sudo` privileges to install packages
- Debian 13 Trixie or greater. For the correct `GCC` compiler and libs
- Edit your `/etc/apt/sources.list` and **remove** `#` on lines with `deb-src` to enable source packaging else will not install properly especially Hyprland

```bash
sudo nano /etc/apt/sources.list
```

- Delete `#` on the lines with `deb-src`
- Make sure to install `non-free` repository especially for users with NVIDIA GPUs. You can also install non-free drivers if required.
    - Edit `install-scripts/nvidia.sh` and change the NVIDIA settings if required

> Note: For users with newer NVIDIA GPUs, especially, RTX5000 series, we strongly suggest you manually install the current `open` drivers for NVIDIA
> Not install them from Jak's Debian install script

### 🪧🪧🪧 ANNOUNCEMENT 🪧🪧🪧

[Debian-Hyprland Changelogs](https://github.com/JaKooLit/Debian-Hyprland/blob/main/CHANGELOGS.md)

- 10 January 2026 Update!
- Debian now builds Hyprland v0.53.2!
    - This requires the just released `Debian-Hyprland v2.9.4` installer
    - Debian 13 (`Trixie`, aka `Stable`)
    - While it does now support v0.53.2
            - At this time it should not be used for production
            - Testing is on going but NVIDIA GPUs have not been tested
            - Intel, AMD, and in VMs only so far
    - Debian Testing (`Forky`) and Unstable (`SID`) - Build and run Hyprland v0.53.2 without issue

- 10 October 2025 Update!
- Hyprland-Debian nows builds 0.51.1 from source!
    - The installer now can be used to install newer releases later
- If you are currently running 0.49, or 0.50, you can upgrade to 0.51.1 > Note: Newer Hyprland versions (0.53.x+) may require compatibility shims on Debian 13 (Trixie). > Use the provided update/install scripts with `--build-trixie` if needed.
    - You do not have to re-install everything, but re-running `install.sh` works also
    - Instructions are available in English and Spanish

#### ✨ Some notes on this installer / Prerequisites

- Recommend installing SDDM. Apart from GDM and SDDM, other Login Managers may not launch `Hyprland`.
    - yprland can be launched through tty by typing:
        - Prior to Hyprland v0.53.x `Hyprland` or `hyprland`
        - After Hyprland v0.53.x you must use `start-hyprland`
            - Otherwise will generate and error at start up.
            - You might need to update the login manager if not using SDDM or GDM
- 🕯️ network-manager-gnome (nm-applet) _has been removed_ from the packages to install. This is because it is known to restart the networkmanager causing issues in the installation process. After you boot up, inorder to get the network-manager applet, install network-manager-gnome. `sudo apt install network-manager-gnome` See below if your network or wifi became unmanaged after installation

### 🚩 changing login manager to SDDM

- if you really want to change login manager, there are couple of things you need to carry out before running this install script
- first install sddm. the no-install-recommends is suggested else it will pull lots of plasma depencies.

```bash
sudo apt install --no-install-recommends -y sddm
```

- then ran `sudo dpkg-reconfigure sddm` choose sddm and then reboot.
- once reboot done, you can ran the script and choose sddm & sddm theme
- [LINK](https://www.simplified.guide/ubuntu/switch-to-gdm) for some guide

#### 💫 SDDM and GTK Themes offered

- If you opted to install SDDM theme, here's the [LINK](https://github.com/JaKooLit/simple-sddm-2) which is a modified fork of [LINK](https://github.com/Keyitdev/sddm-astronaut-theme)
- If you opted to install GTK Themes, Icons, here's the [LINK](https://github.com/JaKooLit/GTK-themes-icons). This also includes Bibata Modern Ice cursor.

#### 🔔 NOTICE TO NVIDIA OWNERS

- By default it is installing the latest and newest **proprietary** NVIDIA drivers. If you have an older NVIDIA GPU (GTX 800 series and older), check out nvidia-debian website [LINK](https://wiki.debian.org/NvidiaGraphicsDrivers) and edit nvidia.sh in install-scripts directory to install proper gpu driver
- If you have NVIDIA, and wanted to use proprietary drivers, uninstall nouveau first (if installed).
- This script will install proprietary NVIDIA and will not deal with removal of nouveau.

## > NOTE: If you have new NVIDIA GPUs, RTX5000+ then do **NOT** install these drivers!! Newer GPUs require the open drivers

> Install those first, before installing Hyprland

- NVIDIA users / owners, after installation, check [`THIS`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Notes_to_remember#--for-nvidia-gpu-users)

> [!IMPORTANT]
> If you wish to use the nouveau driver (installed by default in Debian), be sure to not select "NVIDIA" in the installation options.
> See note above about new NVIDIA GPUs.

> If you select this option, the NVIDIA installer part will attempt to blacklist nouveau; while Hyprland will still be installed, it will skip blacklisting nouveau if you don't select the NVIDIA option.

## ✨ Auto clone and install

> [!CAUTION]
> If you are using FISH SHELL, DO NOT use this function. Clone and run `install.sh` instead

- you can use this command to automatically clone the installer and ran the script for you
- NOTE: `curl` package is required before running this command

```bash
sh <(curl -L https://raw.githubusercontent.com/JaKooLit/Debian-Hyprland/main/auto-install.sh)
```

## ✨ to use this script

clone this repo, change directory, make executable and run the script:

```bash
git clone --depth=1 https://github.com/JaKooLit/Debian-Hyprland.git ~/Debian-Hyprland
cd ~/Debian-Hyprland
chmod +x install.sh
./install.sh
```

#### ✨ TO DO once installation done and dotfiles copied

- SUPER H for HINT or click on the waybar HINT! Button
- Head over to [`FAQ`](https://github.com/JaKooLit/Hyprland-Dots/wiki/FAQ) and [`TIPS`](https://github.com/JaKooLit/Hyprland-Dots/wiki/TIPS)
- Head over to [KooL Hyprland WIKI](https://github.com/JaKooLit/Hyprland-Dots/wiki)

- if you installed in your laptop and Brightness and Keyboard brightness does not work you can execute this command `sudo chmod +s $(which brightnessctl)`

#### ✨ Packages that are manually downloaded and build. These packages will not be updated by apt and have to be manually updated

- Asus ROG asusctl [`LINK`](https://gitlab.com/asus-linux/asusctl) and superfxctl [`LINK`](https://gitlab.com/asus-linux/supergfxctl)
- swww [`LINK`](https://github.com/Horus645/swww)
- hyprlock [`LINK`](https://github.com/hyprwm/hyprlock) #22 Aug 2024 - still not on repo
- hypridle [`LINK`](https://github.com/hyprwm/hypridle) #22 Aug 2024 - still not on repo
- rofi-wayland [`LINK`](https://github.com/lbonn/rofi)
- wallust [`LINK`](https://codeberg.org/explosion-mental/wallust)

> [!TIP]
> To update to latest packages, re-running this script will auto update all. Script is configured to pull latest packages build for you.

### 💥 UNINSTALL SCRIPT / Removal of Config Files

- 11 March 2025, due to popular request, created a guided `uninstall.sh` script. USE this with caution as it may render your system unstable.
- I will not be responsible if your system breaks
- The best still to revert to previous state of your system is via **timeshift or snapper**

#### 🤬 FAQ

**Most common question I got is, Hey Ja, Why the heck it is taking long time to install? Other distro like Arch its only a minute or two. Why here takes like forever?!?!?**

- Most of the core packages are downloaded, some have to be compiled from source.
    - Unlike Other distros, these packages already have prepacked binary that can just download and install.
    - This adds to the install time

## 🛎 **_DEBIAN Hyprland Dots UPDATING NOTES_**

- With this new update to Debian-Hyprland the current Hyprland-Dots are now compatible with Debian.

> [!NOTE]
> This script does not setup audio. Kindly set up. If you have not, I recommend pipewire. `sudo apt install -y pipewire`

#### 🙋 Got a questions regarding the Hyprland Dots or configurations? 🙋

Head over to wiki Link [`WIKI`](https://github.com/JaKooLit/Hyprland-Dots/wiki)

#### ⌨ Keybinds

Keybinds [`CLICK`](https://github.com/JaKooLit/Hyprland-Dots/wiki/Keybinds)

> [!TIP]
> KooL Hyprland has a searchable keybind rofi menu. (`SUPER SHIFT K`) or right click the `HINTS` waybar button

#### 🙋 👋 Having issues or questions?

- for the install part, kindly open issue on this repo
- for the Pre-configured Hyprland dots / configuration, submit issue [`here`](https://github.com/JaKooLit/Hyprland-Dots/issues)

#### 🔧 Proper way to re-installing a particular script from install-scripts directory

- CD into Debian-Hyprland directory and then ran the below command.
- i.e. `./install-scripts/gtk-themes.sh` - to reinstall GTK Themes or
- `./install-scripts/sddm.sh` - to reinstall sddm

> [!IMPORTANT]
> DO NOT CD into `install-scripts` directory to run any of those scripts
> The scripts are designed to ran outside `install-scripts` directory.
> If you do the scripts will fail.

#### 🛣️ Roadmap

- [ ] possibly adding gruvbox themes, cursors, icons

#### ❗ some known issues for nvidia

- reports from members of my discord, states that some users of nvidia are getting stuck on sddm login. credit to @Kenni Fix stated was

```
 while in sddm press ctrl+alt+F2 or F3
log into your account
`lspci -nn`, find the id of your nvidia card
`ls /dev/dri/by-path` find the matching id
`ls -l /dev/dri/by-path` to check where the symlink points to
)
```

- add `env = WLR_DRM_DEVICES,/dev/dri/cardX` to the ENVvariables config `~/.config/hypr/UserConfigs/ENVariables.conf` ; X being where the symlink of the gpu points to

- more info from the hyprland wiki [`Hyprland Wiki Link`](https://wiki.hyprland.org/FAQ/#my-external-monitor-is-blank--doesnt-render--receives-no-signal-laptop)

- reports from a member of discord for Nvidia for additional env's
- remove # from the following env's on

```
env = GBM_BACKEND,nvidia-drm
env = WLR_RENDERER_ALLOW_SOFTWARE,1
```

#### 🫥 Improving performance for Older Nvidia Cards using driver 470

- [`SEE HERE`](https://github.com/JaKooLit/Hyprland-Dots/discussions/123#discussion-6035205)

#### ❗ other known issues

> [!NOTE]
> Auto start of Hyprland after login (no SDDM or GDM or any login managers)

- This was disabled a few days ago. (19 May 2024). This was because some users, after they used the Distro-Hyprland scripts with other DE (gnome-wayland or plasma-wayland), if they choose to login into gnome-wayland for example, Hyprland is starting.
- to avoid this, I disabled it. You can re-enable again by editing `~/.zprofile` . Remove all the # on the first lines
- [ ] ROFI issues (scaling, unexplained scaling etc). This is most likely to experience if you are installing on a system where rofi is currently installed. To fix it uninstall rofi and install rofi-wayland . `sudo apt autoremove rofi` .
- Install rofi-wayland with

```bash
cd ~/Debian-Hyprland
./install-scripts/rofi-wayland.sh
```

- [ ] Rofi-wayland is compatible with x11 so no need to worry.

- [ ] Does not work in Debian Bookworm
- [ ] sddm blackscreen when log-out
- [ ] Installing SDDM if or any other Login Manager installed. See [`Issue 2 - SDDM`](https://github.com/JaKooLit/Debian-Hyprland/issues/2)
- [ ] network is down or become unmanaged [`This`](https://askubuntu.com/questions/71159/network-manager-says-device-not-managed) might help

#### 📒 Final Notes

- join my discord channel [`Discord`](https://discord.com/invite/kool-tech-world)
- Feel free to copy, re-distribute, and use this script however you want. Would appreciate if you give me some loves by crediting my work :)

#### ✍️ Contributing

- As stated above, these script does not contain actual config files. These are only the installer of packages
- If you want to contribute and/or test the Hyprland-Dotfiles (development branch), [`Hyprland-Dots-Development`](https://github.com/JaKooLit/Hyprland-Dots/tree/development)
- Want to contribute on KooL-Hyprland-Dots Click [`HERE`](https://github.com/JaKooLit/Hyprland-Dots/blob/main/CONTRIBUTING.md) for a guide how to contribute
- Want to contribute on This Installer? Click [`HERE`](https://github.com/JaKooLit/Debian-Hyprland/blob/main/CONTRIBUTING.md) for a guide how to contribute

#### 👍👍👍 Thanks and Credits

- [`Hyprland`](https://hyprland.org/) Of course to Hyprland and @vaxerski for this awesome Dynamic Tiling Manager.

### 💖 Support

- a Star on my Github repos would be nice 🌟

- Subscribe to my Youtube Channel [YouTube](https://www.youtube.com/@Ja.KooLit)

- you can also give support through coffee's or btc 😊

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/jakoolit)

or

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/JaKooLit)

Or you can donate cryto on my btc wallet :)

> 1N3MeV2dsX6gQB42HXU6MF2hAix1mqjo8i

![Bitcoin](https://github.com/user-attachments/assets/7ed32f8f-c499-46f0-a53c-3f6fbd343699)

#### 📹 Youtube videos (Click to view and watch the playlist) 📹

[![Youtube Playlist Thumbnail](https://raw.githubusercontent.com/JaKooLit/screenshots/main/Youtube.png)](https://youtube.com/playlist?list=PLDtGd5Fw5_GjXCznR0BzCJJDIQSZJRbxx&si=iaNjLulFdsZ6AV-t)

## 🥰🥰 💖💖 👍👍👍

[![Stargazers over time](https://starchart.cc/JaKooLit/Debian-Hyprland.svg?variant=adaptive)](https://starchart.cc/JaKooLit/Debian-Hyprland)
