#!/bin/bash

sudo rm /etc/udev/rules.d/10-disable-internal-keyboard.rules

sudo udevadm control --reload-rules
sudo udevadm trigger
