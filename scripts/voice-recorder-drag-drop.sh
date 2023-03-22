#!/bin/bash

VOICE_RECORDER_FILE="$HOME/voicemessage.ogg"
RECORD_COMMAND="ffmpeg -f pulse -i default -ac 1 -ar 48000 -c:a libopus -y $VOICE_RECORDER_FILE"

alacritty --config-file "$ALACRITTY_CONFIG" --class "voice-recorder-drag-drop" -e $RECORD_COMMAND 

dragon-drop $VOICE_RECORDER_FILE

rm $VOICE_RECORDER_FILE

