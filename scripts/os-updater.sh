#!/bin/bash

UPDATE_COMMAND="arch-updater"

alacritty --config-file "$ALACRITTY_CONFIG" --class update --hold -e "$UPDATE_COMMAND"
#notify-send 'The system has been updated' 

