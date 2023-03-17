#!/bin/bash

entries=" Lock\n⇠   Logout\n⏾ Suspend\n󰑓 Reboot\n⏻ Shutdown"

selected=$(echo -e $entries|wofi -i --width 220 --height 200 --dmenu --cache-file /dev/null | awk '{print tolower($2)}')

WALLPAPER=~/Nextcloud/Wallpapers/cat_pacman.png

case $selected in
  lock)
	  swaylock -i "$WALLPAPER";;
  logout)
    hyprctl dispatch exit;;
  suspend)
    exec systemctl suspend;;
  reboot)
    exec systemctl reboot;;
  shutdown)
    exec systemctl poweroff -i;;
esac
