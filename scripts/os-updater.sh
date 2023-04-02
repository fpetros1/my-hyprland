#!/bin/bash

perform_update() {
	alacritty --config-file "$ALACRITTY_CONFIG" --class update --hold -e $SHELL -c "$UPDATE_COMMAND"
}

OS_UPDATE_COMMAND="arch-updater"
FLATPAK_UPDATE_COMMAND="flatpak update"

FLATPAK_COMMAND=$(command -v flatpak)

if [ ! -z $FLATPAK_COMMAND ]; then	
	UPDATE_COMMAND="$OS_UPDATE_COMMAND && $FLATPAK_UPDATE_COMMAND"
	perform_update
	exit
fi

UPDATE_COMMAND="$OS_UPDATE_COMMAND"
perform_update

