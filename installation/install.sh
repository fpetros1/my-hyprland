#!/bin/bash

PACKAGES_FILE="hyprland-arch-core-packages"
SCRIPT_WD="$( cd "$( dirname "$0" )" && pwd )"
HYPRLAND_CONFIG="$HOME/.config/hypr"
SDDM_CONFIG="/etc/sddm.conf"
KEYD_CONFIG="/etc/keyd/default.conf"
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
MONITORS_FILE="$SCRIPT_WD/../monitors.conf" 
if [ ! -f "$MONITORS_FILE" ]; then
    echo "WARNING: '$MONITORS_FILE' does not exist, defaulting to auto monitor config in hyprland. CTRL + C to Cancel"
	TIMER=5
	while [ "$TIMER" -gt 0 ]; do
		echo "$TIMER"
		sleep 1
		TIMER=$(echo $[TIMER-1])
	done
	cp "$SCRIPT_WD/../monitors.auto.conf" "$SCRIPT_WD/../monitors.conf" 
fi

# Create Staging Folder
mkdir -p $STAGING_FOLDER && cd $STAGING_FOLDER

# Install Git
sudo pacman -Syu --needed git base-devel findutils

# Clone and install Paru/Yay
# Paru
PARU_BUILD_FOLDER="paru-bin"
rm -rf $STAGING_FOLDER/$PARU_BUILD_FOLDER
git clone "$PARU_GIT_URL" && cd $PARU_BUILD_FOLDER
makepkg --needed --noconfirm -si && cd $STAGING_FOLDER
# Yay
YAY_BUILD_FOLDER="yay-bin"
rm -rf $STAGING_FOLDER/$YAY_BUILD_FOLDER
git clone "$YAY_GIT_URL" && cd $YAY_BUILD_FOLDER
makepkg --needed --noconfirm -si && cd $STAGING_FOLDER

# Uninstall xdg-desktop-portal implementations that cause problems with hyprland's 
paru -R xdg-desktop-portal-wlr xdg-desktop-portal-gnome
paru -Rnsdd xdg-desktop-portal-kde

# Remove conflicting packages
paru -R cantarell-fonts

# Install my Hyprland core packages
CORE_PACKAGES=$(echo "$(cat $SCRIPT_WD/$PACKAGES_FILE | xargs)")
IFS=" " read -ra PACKAGE <<<  "$CORE_PACKAGES"
for package in "${PACKAGE[@]}"; do
	paru --noconfirm --needed -S $package
done

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
cp -r $SCRIPT_WD/../* $HYPRLAND_CONFIG

# Link Alacritty Files
mkdir -p $HOME/.config/alacritty
ln -s $HYPRLAND_CONFIG/alacritty $HOME/.config/alacritty

# Copy Files to Home
cp -r $SCRIPT_WD/home/. $HOME

# Delete installation Folder
rm -r $HYPRLAND_CONFIG/installation

# Delete Git Files
rm -rf $HYPRLAND_CONFIG/.git
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

# Enable Cronie for Timeshift scheduled Backups
sudo systemctl enable cronie

# Download and set SDDM theme
SDDM_THEME_FOLDER="sddm"
FLAVOUR="mocha"
git clone "$CATPPUCCIN_SDDM_THEME_GIT_URL" && cd $SDDM_THEME_FOLDER
sudo mkdir -p /usr/share/sddm/themes
sudo cp -r "src/catppuccin-$FLAVOUR" /usr/share/sddm/themes
sudo rm $SDDM_CONFIG
echo "[Theme]" | sudo tee -a $SDDM_CONFIG
echo "Current=catppuccin-$FLAVOUR" | sudo tee -a $SDDM_CONFIG
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
cd $STAGING_FOLDER

# Setup keyd
sudo systemctl enable keyd
echo "[ids]" | sudo tee -a $KEYD_CONFIG
echo "*" | sudo tee -a $KEYD_CONFIG
echo "[main]" | sudo tee -a $KEYD_CONFIG
echo "rightmeta = home" | sudo tee -a $KEYD_CONFIG

# Setup ydotool
sudo usermod -aG input $USER
systemctl --user enable ydotool

# Create Script Links in /usr/bin
exec $HYPRLAND_CONFIG/scripts/update-script-links

# Source .environment and autosuggestions in .zshrc and .bashrc
echo "#Environment" | tee -a $HOME/.zshrc
echo "source $HOME/.environment" | tee -a $HOME/.zshrc
echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" | tee -a $HOME/.zshrc
echo "#Environment" | tee -a $HOME/.bashrc
echo "source $HOME/.environment" | tee -a $HOME/.bashrc

cd "$(pwd)"
echo "Done. Please Reboot"

