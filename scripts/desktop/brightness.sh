#!/usr/bin/env bash
set -euo pipefail

NIGHT=0
DAY=50
EXTENSION_DIR=$HOME/.local/share/gnome-shell/extensions/display-brightness-ddcutil@themightydeity.github.com
SCHEMA=org.gnome.shell.extensions.display-brightness-ddcutil

wait=0
value=''
while [[ $# -gt 0 ]]; do
	case $1 in
		--wait)
			wait=$2
			shift 2
			;;
		*)
			value=$1
			shift
			;;
	esac
done

if [[ -z $value ]]; then
	hour=$(date +%H)
	if (( 10#$hour >= 21 || 10#$hour < 7 )); then
		value=$NIGHT
	else
		value=$DAY
	fi
fi

sleep "$wait"

ok=0
for _ in 1 2 3; do
	if ddcutil setvcp 10 "$value"; then
		ok=1
		break
	fi
	sleep 3
done
[[ $ok -eq 1 ]] || exit 1

sync_extension_slider() {
	[[ -d $EXTENSION_DIR ]] || return 0
	local current flip
	current=$(GSETTINGS_SCHEMA_DIR="$EXTENSION_DIR/schemas" gsettings get "$SCHEMA" verbose-debugging 2>/dev/null) || return 0
	if [[ $current == 'true' ]]; then
		flip=false
	else
		flip=true
	fi
	GSETTINGS_SCHEMA_DIR="$EXTENSION_DIR/schemas" gsettings set "$SCHEMA" verbose-debugging "$flip"
	GSETTINGS_SCHEMA_DIR="$EXTENSION_DIR/schemas" gsettings set "$SCHEMA" verbose-debugging "$current"
}

sync_extension_slider
