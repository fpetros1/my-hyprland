#!/bin/bash

GUI="$1"

if [ "$GUI" == "gui" ]; then
	CMD=$([[ $TERMINAL == "alacritty" ]] && echo "-e $0" || echo "$0")
	exec $TERMINAL --class "update" --hold $CMD
	exit
fi

OS_UPDATE_COMMAND="arch-updater"
FLATPAK_UPDATE_COMMAND="flatpak update"

FLATPAK_COMMAND=$(command -v flatpak)

UPDATE_COMMAND="$OS_UPDATE_COMMAND"

echo -e "\n────────── System Update ──────────\n"
$SHELL -c "$UPDATE_COMMAND"

if [ ! -z $FLATPAK_COMMAND ]; then
	echo -e "\n────────── Flatpak Update ──────────\n"
	$SHELL -c "$FLATPAK_UPDATE_COMMAND"
fi

