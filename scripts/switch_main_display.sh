if xrandr | grep -q "^DisplayPort-3 connected"; then
    xrandr --output DisplayPort-1 --primary
fi
