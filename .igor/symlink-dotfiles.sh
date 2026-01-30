#---
# description: Update symlinks to different folders and files
#---

log_comment "Update the symlinks!"

create_symlink() {
		local source="$1"
		local target="$2"
		if [ ! -e "$target" ]; then
				ln -s "$source" "$target"
				log_success "Created symlink: $target -> $source"
		else
				if [ -L "$target" ]; then
						if [ "$(readlink -f "$target")" = "$source" ]; then
								log_success "Correct symlink already exists: $target"
						else
								log_error "Symlink exists but points to the wrong location: $target"
						fi
				elif [ -e "$target" ]; then
						log_error "A file or directory already exists at the target location: $target"
				fi
		fi
}

create_symlink ~/.dotfiles/git/.gitconfig ~/.gitconfig
create_symlink ~/.dotfiles/git/.gitignore.global ~/.gitignore.global
create_symlink /dev/null ~/Pictures/Screenshots
create_symlink ~/.dotfiles/atuin ~/.config/atuin
create_symlink ~/.dotfiles/fish ~/.config/fish
create_symlink ~/.dotfiles/lazygit ~/.config/lazygit
create_symlink ~/.dotfiles/just ~/.config/just
create_symlink ~/.dotfiles/kitty ~/.config/kitty
create_symlink ~/.dotfiles/mise ~/.config/mise
create_symlink ~/.dotfiles/nvim ~/.config/nvim
create_symlink ~/.dotfiles/posting ~/.config/posting
create_symlink ~/.dotfiles/starship ~/.config/starship
create_symlink ~/.dotfiles/vicinae ~/.config/vicinae
create_symlink ~/.dotfiles/wezterm ~/.config/wezterm
create_symlink ~/.dotfiles/yazi ~/.config/yazi
