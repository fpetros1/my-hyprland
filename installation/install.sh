#!/bin/bash

PACKAGES_FILE="hyprland-arch-core-packages"
SCRIPT_WD="$( cd "$( dirname "$0" )" && pwd )"
HYPRLAND_CONFIG="$HOME/.config/hypr"
SDDM_CONFIG="/etc/sddm.conf"
STAGING_FOLDER="$HOME/Staging"
PARU_GIT_URL="https://aur.archlinux.org/paru-bin.git"
YAY_GIT_URL="https://aur.archlinux.org/yay-bin.git"
XPAD_GIT_URL="https://github.com/paroj/xpad.git"
WIN_INTL_KEYBOARD_GIT_URL="https://github.com/fpetros1/win_us_intl"
CATPPUCCIN_SDDM_THEME_GIT_URL="https://github.com/catppuccin/sddm"
CATPPUCCIN_QT5CT_GIT_URL="https://github.com/catppuccin/qt5ct"
NVIM_GIT_URL="https://github.com/fpetros1/nvim-config"
PACKER_GIT_URL="https://github.com/wbthomason/packer.nvim"

# Check if monitor file exists, give the user a chance to stop if not
MONITORS_FILE="$SCRIPT_WD/monitors.conf" 
if [ ! -f "$MONITORS_FILE" ]; then
    echo "WARNING: '$MONITORS_FILE' does not exist, defaulting to auto monitor config in hyprland. CTRL + C to Cancel"
	TIMER=5
	while [ "$TIMER" -gt 0 ]; do
		echo "$TIMER"
		sleep 1
		TIMER=$(echo $[TIMER-1])
	done
	cp "$SCRIPT_WD/monitors.auto.conf" "$SCRIPT_WD/monitors.conf" 
fi

# Create Staging Folder
mkdir -p $STAGING_FOLDER && cd $STAGING_FOLDER

# Install Git
yes | LC_ALL=en_US.UTF-8 sudo pacman -S --needed git base-devel findutils

# Clone and install Paru/Yay
# Paru
PARU_BUILD_FOLDER="paru-bin"
rm -rf $STAGING_FOLDER/$PARU_BUILD_FOLDER
git clone "$PARU_GIT_URL" && cd $PARU_BUILD_FOLDER
yes | LC_ALL=en_US.UTF-8 makepkg -si && cd $STAGING_FOLDER
# Yay
YAY_BUILD_FOLDER="yay-bin"
rm -rf $STAGING_FOLDER/$YAY_BUILD_FOLDER
git clone "$YAY_GIT_URL" && cd $YAY_BUILD_FOLDER
yes | LC_ALL=en_US.UTF-8 makepkg -si && cd $STAGING_FOLDER

# Uninstall xdg-desktop-portal implementations that cause problems with hyprland's 
yes | LC_ALL=en_US.UTF-8 paru -R xdg-desktop-portal-wlr xdg-desktop-portal-gnome
yes | LC_ALL=en_US.UTF-8 paru -Rnsdd xdg-desktop-portal-kde

# Install my Hyprland core packages
CORE_PACKAGES=$(echo "$(cat $SCRIPT_WD/$PACKAGES_FILE | xargs)")
yes | LC_ALL=en_US.UTF-8 paru -Syu $CORE_PACKAGES

# Install Xpad with support for 8bitdo Ultimate Controller
sudo git clone "$XPAD_GIT_URL" /usr/src/xpad-0.4
sudo dkms install -m xpad -v 0.4 --force

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install .XCompose with support for ç
WIN_INTL_BUILD_FOLDER="win_us_intl"
git clone "$WIN_INTL_KEYBOARD_GIT_URL" && cd $WIN_INTL_BUILD_FOLDER
cp .XCompose $HOME && cd $STAGING_FOLDER

# Copy Hyprland Files
rm -rf $HYPRLAND_CONFIG
mkdir -p $HYPRLAND_CONFIG
cp -r $SCRIPT_WD/* $HYPRLAND_CONFIG

# Copy Files to Home
cp -r $HYPRLAND_CONFIG/home/* $HOME && rm -r $HYPRLAND_CONFIG/home

# Delete installation Folder
rm -r $HYPRLAND_CONFIG/installation

# Delete Git Files
rm $HYPRLAND_CONFIG/.gitignore
rm $HYPRLAND_CONFIG/README.md
rm $HYPRLAND_CONFIG/LICENSE.md

# Try to disable other login managers and enable sddm
sudo systemctl disable ly
sudo systemctl disable gdm
sudo systemctl disable lightdm
sudo systemctl disable xdm
sudo systemctl disable lxdm
sudo systemctl enable sddm

# Download and set SDDM theme
SDDM_THEME_FOLDER="sddm"
FLAVOUR="mocha"
git clone "$CATPPUCCIN_SDDM_THEME_GIT_URL" && cd $SDDM_THEME_FOLDER
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r "src/catppuccin-$FLAVOUR" /usr/share/sddm/themes
sudo echo "[Theme]" >> $SDDM_CONFIG
sudo echo "Current=catppuccin-$FLAVOUR" >> $SDDM_CONFIG
cd $STAGING_FOLDER

# Download and setup My NeoVim + Packer
NVIM_FOLDER="nvim-config"
git clone --depth 1 "$PACKER_GIT_URL" $HOME/.local/share/nvim/site/pack/packer/start/packer.nvim
git clone "$NVIM_GIT_URL" && cd "$NVIM_FOLDER"
cp -r . $HOME/.config/nvim
cd $STAGING_FOLDER

# Install Catppuccin qt5ct color scheme
QT5CT_FOLDER="qt5ct"
FLAVOUR="Mocha"
COLORS_FOLDER="$HOME/.config/qt5ct/colors"
mkdir -p "$COLORS_FOLDER"
git clone "$CATPPUCCIN_QT5CT_GIT_URL" && cd $QT5CT_FOLDER
cp "Catppuccin-${FLAVOUR}.conf" "$COLORS_FOLDER" 

# Source .environment in .zshrc and .bashrc
echo "#Environment\nsource $HOME/.environment\n" >> $HOME/.zshrc
echo "#Environment\nsource $HOME/.environment\n" >> $HOME/.bashrc

cd "$(pwd)"
echo "\nDone."

