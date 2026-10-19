#!/usr/bin/env bash

# List of app executables to patch
APPS=(
  "ferdium"
  "mattermost-desktop"
  "obsidian"
)

WRAPPER="$HOME/.dotfiles/scripts/electron/electron_wayland_wrapper"
DESKTOP_USER="$HOME/.local/share/applications"
DESKTOP_SYS="/usr/share/applications"

mkdir -p "$DESKTOP_USER"

patch_desktop() {
  local app="$1"
  local desktop_file

  # Find .desktop file (prefer user copy)
  if [[ -f "$DESKTOP_USER/${app}.desktop" ]]; then
    desktop_file="$DESKTOP_USER/${app}.desktop"
  elif [[ -f "$DESKTOP_SYS/${app}.desktop" ]]; then
    cp "$DESKTOP_SYS/${app}.desktop" "$DESKTOP_USER/"
    desktop_file="$DESKTOP_USER/${app}.desktop"
  else
    echo "⚠️  No .desktop file found for: $app"
    return
  fi

  # Patch Exec line (only if not already using wrapper)
  if ! grep -q "$WRAPPER" "$desktop_file"; then
    sed -i -E "s|^Exec=.*|Exec=$WRAPPER ${app} %U|g" "$desktop_file"
    echo "✅ Patched: $desktop_file"
  else
    echo "✔️ Already patched: $app"
  fi
}

for app in "${APPS[@]}"; do
  patch_desktop "$app"
done

# Refresh desktop entries (optional)
update-desktop-database "$DESKTOP_USER" 2>/dev/null

echo "Done."
