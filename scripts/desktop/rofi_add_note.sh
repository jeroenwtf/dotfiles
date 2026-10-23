#!/bin/bash
set -e

NOTE=$(rofi -dmenu -p "Add note" -no-match -lines 0 -theme-str 'entry { placeholder: "Type the note content"; }')
FILE="$HOME/Obsidian/00 - Inbox/Quick notes.md"
DATE=$(date +"%Y-%m-%d %H:%M")

if echo "- [ ] \`$DATE\` $NOTE" >> "$FILE"; then
    exit 0
else
    notify-send -u critical "Error" "Failed to add note to $FILE"
    exit 1
fi

