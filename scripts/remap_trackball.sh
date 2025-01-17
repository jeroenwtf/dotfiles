#!/bin/sh

# Elecom Huge Trackball Mapping
ELECOM_ID=$(xinput list | grep "ELECOM" | head -n 1 | sed -r 's/.*id=([0-9]+).*/\1/')

# LC MC RC ? ? WHEEL_UP WHEEL_DOWN BACK FORW FN1 FN2 FN3
# 1  2  3  4 5 6        7          8    9    10  11  12

# Remap buttons (FORW to LC, FN2 to MC)
xinput --set-button-map ${ELECOM_ID} 1 2 3 4 5 6 7 8 1 10 2 12

# Remap FN1 to "hold to scroll"
xinput --set-prop ${ELECOM_ID} "libinput Scroll Method Enabled" 0, 0, 1
xinput --set-prop ${ELECOM_ID} "libinput Button Scrolling Button" 10
