#!/bin/bash

PACKAGE_MANAGER="paru"

alacritty --config-file "$ALACRITTY_CONFIG" --class update -e "$PACKAGE_MANAGER" -Syu
notify-send 'The system has been updated' 

