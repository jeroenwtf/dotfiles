#!/bin/bash
set -e

TODO=$(rofi -dmenu -p "Add todo" -no-match -lines 0 -theme-str 'entry { placeholder: "Type what you want to do"; }')

if [[ -n $TODO ]]; then
    if tod t q -c "$TODO"; then
        notify-send -a Todoist "Saved TODO: $TODO"
    else
        notify-send -a Todoist -u critical "Error: Failed to save TODO"
    fi
fi

