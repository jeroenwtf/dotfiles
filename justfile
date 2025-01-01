setup:
    @just symlink-dotfiles

    @just install-pacman-packages
    @just install-aur-packages

    @just install-mise-tools
    @just install-npm-packages
    @just install-gems

    @just install-gnome-extensions-cli
    @just install-gnome-extensions
    @just enable-shortcuts

    @just set-default-shell
    @just install-fisher-and-plugins

    @just enable-services

[group('chores')]
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

[group('chores')]
install-gnome-extensions-cli:
    pipx install gnome-extensions-cli --system-site-packages

[group('install packages')]
install-gnome-extensions:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r extension; do
        gext install "$extension"
    done < packages/gnome.list

[group('chores')]
install-mise-tools:
    mise use -g usage

    mise use -g node@lts
    mise install node@lts

    mise use -g ruby@latest
    mise install ruby

[group('install packages')]
install-npm-packages:
    #!/usr/bin/env bash
    set -euo pipefail
    while IFS= read -r package || [[ -n "$package" ]]; do
        if [[ ! "$package" =~ ^\s*# && -n "$package" ]]; then
            npm install -g "$package"
        fi
    done < packages/npm.list

[group('install packages')]
install-gems:
    xargs -a packages/gem.list gem install

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

[group('chores')]
symlink-dotfiles:
    #!/usr/bin/env bash
    set -euo pipefail

    create_symlink() {
        local source="$1"
        local target="$2"
        if [ ! -e "$target" ]; then
            ln -s "$source" "$target"
            echo "Created symlink: $target -> $source"
        else
            echo "Symlink already exists: $target"
        fi
    }

    create_symlink ~/.dotfiles/git/.gitconfig ~/.gitconfig
    create_symlink ~/.dotfiles/git/.gitignore.global ~/.gitignore.global
    create_symlink ~/.dotfiles/fish ~/.config/fish
    create_symlink ~/.dotfiles/lazygit ~/.config/lazygit
    create_symlink ~/.dotfiles/kitty ~/.config/kitty
    create_symlink ~/.dotfiles/mise ~/.config/mise
    create_symlink ~/.dotfiles/nvim ~/.config/nvim
    create_symlink ~/.dotfiles/rofi ~/.config/rofi
    create_symlink ~/.dotfiles/wezterm ~/.config/wezterm
    create_symlink ~/.dotfiles/starship ~/.config/starship
    create_symlink /dev/null ~/Pictures/Screenshots

[group('chores')]
backup-shortcuts:
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ > ~/.dotfiles/gnome/custom_keybindings.dconf

[group('chores')]
enable-shortcuts:
    dconf load /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ < ~/.dotfiles/gnome/custom_keybindings.dconf
