#!/bin/bash

rm /etc/udev/rules.d/10-disable-internal-keyboard.rules

udevadm control --reload-rules
udevadm trigger
