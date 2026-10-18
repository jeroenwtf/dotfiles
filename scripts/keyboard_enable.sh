#!/bin/bash
set -euo pipefail

DEVICE_NAME="Framework Laptop 16 Keyboard Module - ANSI Keyboard"
RULES_FILE=/etc/udev/rules.d/10-disable-internal-keyboard.rules

if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
fi

rm -f "$RULES_FILE"

udevadm control --reload-rules

# Re-trigger each matching device with a remove/add pair so the running
# compositor picks it up again without a restart.
event_nodes() {
    awk -v dev="$DEVICE_NAME" '
        /^N: Name=/  { sub(/^N: Name=/, ""); name = $0; gsub(/"/, "", name) }
        /^H: Handlers=/ {
            if (name == dev)
                for (i = 1; i <= NF; i++)
                    if ($i ~ /^event[0-9]+$/)
                        print "/dev/input/" $i
        }
    ' /proc/bus/input/devices
}

for node in $(event_nodes); do
    echo "Enabling $node"
    udevadm trigger --action=remove --name-match="$node"
    udevadm trigger --action=add --name-match="$node"
done
