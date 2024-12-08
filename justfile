setup:
    @just symlink-dotfiles
    @just install-pacman-packages
    @just install-aur-packages
    @just install-node
    @just install-npm-packages
    @just install-gnome-extensions-cli
    @just install-gnome-packages
    @just setup-fish
    @just enable-services

setup-fish:
    @just set-default-shell
    @just install-fisher-and-plugins

enable-services:
    sudo systemctl enable --now docker.service
    sudo systemctl enable --now postgresql.service
    sudo systemctl enable --now redis.service

[group('install packages')]
install-pacman-packages:
    sudo pacman -S --needed - < packages/pacman.list

[group('install packages')]
install-aur-packages:
    yay -S --needed - < packages/aur.list

install-gnome-extensions-cli:
    pipx install gnome-extensions-cli --system-site-packages

[group('install packages')]
install-gnome-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r extension; do
        gext install "$extension"
    done < packages/gnome.list

install-node:
    mise use node@lts
    mise install node@lts

[group('install packages')]
install-npm-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r package || [[ -n "$package" ]]; do
        if [[ ! "$package" =~ ^\s*# && -n "$package" ]]; then
            npm install -g "$package"
        fi
    done < packages/npm.list

[group('fish')]
set-default-shell:
    chsh -s /usr/bin/fish

[group('fish')]
install-fisher-and-plugins:
    #!/usr/bin/env fish
    if not functions -q fisher
        curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
    end
    fisher update

symlink-dotfiles:
    ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
    ln -s ~/.dotfiles/git/.gitignore.global ~/.gitignore.global
    ln -s ~/.dotfiles/fish ~/.config/fish
    ln -s ~/.dotfiles/lazygit ~/.config/lazygit
    ln -s ~/.dotfiles/kitty ~/.config/kitty
    ln -s ~/.dotfiles/mise ~/.config/mise
    ln -s ~/.dotfiles/nvim ~/.config/nvim
    ln -s ~/.dotfiles/rofi ~/.config/rofi
    ln -s ~/.dotfiles/starship ~/.config/starship
    ln -s /dev/null ~/Pictures/Screenshots
