#!/bin/bash

sleep 2

is_weekday() {
    local day_of_week
    day_of_week=$(date +%u) # 1 (Monday) to 7 (Sunday)
    [[ $day_of_week -lt 6 ]]
}

if is_weekday; then
    wezterm &
    firefox &
    firefox-developer-edition &
    mattermost-desktop &
    ferdium &
fi
