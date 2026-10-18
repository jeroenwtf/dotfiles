#!/usr/bin/env bash
set -euo pipefail

echo "== Installing gnome extensions =="
pipx install gnome-extensions-cli --system-site-packages

while IFS= read -r extension; do
	[ -z "$extension" ] && continue
	gext install "$extension"
done < ~/.dotfiles/packages/gnome.list
