#!/usr/bin/env bash
set -euo pipefail

echo "== Updating symlinks =="

create_symlink() {
	local source="$1"
	local target="$2"
	if [ ! -e "$target" ]; then
		ln -s "$source" "$target"
		echo "created: $target -> $source"
	else
		if [ -L "$target" ]; then
			if [ "$(readlink -f "$target")" = "$source" ]; then
				echo "ok: $target"
			else
				echo "WRONG TARGET: $target -> $(readlink "$target") (expected $source)" >&2
			fi
		else
			echo "EXISTS, NOT A SYMLINK: $target" >&2
		fi
	fi
}

create_symlink ~/.dotfiles/git/.gitconfig ~/.gitconfig
create_symlink ~/.dotfiles/git/.gitignore.global ~/.gitignore.global
create_symlink ~/.dotfiles/scripts/web/link-handler.sh ~/.local/bin/link-handler
create_symlink ~/.dotfiles/link-handler/link-handler.desktop ~/.local/share/applications/link-handler.desktop
create_symlink /dev/null ~/Pictures/Screenshots
create_symlink ~/.dotfiles/pi ~/.pi
create_symlink ~/.dotfiles/atuin ~/.config/atuin
create_symlink ~/.dotfiles/ghostty ~/.config/ghostty
create_symlink ~/.dotfiles/fish ~/.config/fish
create_symlink ~/.dotfiles/lazygit ~/.config/lazygit
create_symlink ~/.dotfiles/just ~/.config/just
create_symlink ~/.dotfiles/mise ~/.config/mise
create_symlink ~/.dotfiles/nvim ~/.config/nvim
create_symlink ~/.dotfiles/posting ~/.config/posting
create_symlink ~/.dotfiles/starship ~/.config/starship
create_symlink ~/.dotfiles/vicinae ~/.config/vicinae
create_symlink ~/.dotfiles/wezterm ~/.config/wezterm
create_symlink ~/.dotfiles/yazi ~/.config/yazi
create_symlink ~/.dotfiles/scripts/desktop/brightness.sh ~/.local/bin/brightness
create_symlink ~/.dotfiles/systemd/brightness-boot.service ~/.config/systemd/user/brightness-boot.service
create_symlink ~/.dotfiles/systemd/brightness-night.service ~/.config/systemd/user/brightness-night.service
create_symlink ~/.dotfiles/systemd/brightness-night.timer ~/.config/systemd/user/brightness-night.timer
create_symlink ~/.dotfiles/systemd/brightness-day.service ~/.config/systemd/user/brightness-day.service
create_symlink ~/.dotfiles/systemd/brightness-day.timer ~/.config/systemd/user/brightness-day.timer
create_symlink ~/.dotfiles/systemd/webhook-notify.service ~/.config/systemd/user/webhook-notify.service
