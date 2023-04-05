#!/bin/bash

TEMP_FOLDER="$HOME/.temp"
VOICE_RECORDER_FILE="$TEMP_FOLDER/voicemessage.ogg"
RECORD_COMMAND="ffmpeg -f pulse -i default -ac 1 -ar 48000 -c:a libopus -y $VOICE_RECORDER_FILE"

mkdir -p $TEMP_FOLDER

alacritty --config-file "$ALACRITTY_CONFIG" --class "voice-recorder-drag-drop" -e $RECORD_COMMAND 

dragon-drop -T $VOICE_RECORDER_FILE

rm $VOICE_RECORDER_FILE

