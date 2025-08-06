#!/bin/bash

declare -A characters

characters=(
    ["Mdash (—)"]="—"
    ["Uppercase c trencada (Ç)"]="Ç"
    ["Lowercase c trencada (ç)"]="ç"
    ["Opening exclamation mark (¡)"]="¡"
    ["Opening question mark (¿)"]="¿"
    ["Euro (€)"]="€"
    ["Catalan dot (·)"]="·"
    ["Trademark (™)"]="™"
)

selection=$(printf "%s\n" "${!characters[@]}" | rofi -dmenu -i -p "Pick a character:")

if [[ -n "$selection" && -n "${characters[$selection]}" ]]; then
    xdotool type "${characters[$selection]}"
fi
