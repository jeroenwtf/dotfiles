#!/bin/bash

DEVICE_NAME="Framework Laptop 16 Keyboard Module - ANSI Keyboard"

echo 'KERNEL=="event*", ATTRS{name}=="'"$DEVICE_NAME"'", ENV{LIBINPUT_IGNORE_DEVICE}="1"' | tee /etc/udev/rules.d/10-disable-internal-keyboard.rules > /dev/null

udevadm control --reload-rules
udevadm trigger
