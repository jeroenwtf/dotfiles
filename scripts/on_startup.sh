#!/bin/bash

# This script runs on startup

script_dir="$(dirname "$0")"

if [ "$HOSTNAME" = "hyperion" ]; then
    "$script_dir/switch_main_display.sh"
fi

"$script_dir/remap_trackball.sh"
"$script_dir/weekday_apps.sh"
