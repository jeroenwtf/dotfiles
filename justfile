setup:
    @just symlink-dotfiles

    @just install-pacman-packages
    @just install-aur-packages

    @just install-mise-tools

    @just install-gnome-extensions-cli
    @just install-gnome-extensions
    @just enable-shortcuts

    @just set-default-shell
    @just install-fisher-and-plugins

    @just enable-services
    @just enable-on-startup-script

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
    mise install

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
            if [ -L "$target" ]; then
                if [ "$(readlink -f "$target")" = "$source" ]; then
                    echo "✓ Correct symlink already exists: $target"
                else
                    echo "Symlink exists but points to the wrong location: $target"
                fi
            elif [ -e "$target" ]; then
                echo "A file or directory already exists at the target location: $target"
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
    create_symlink ~/.dotfiles/rofi ~/.config/rofi
    create_symlink ~/.dotfiles/starship ~/.config/starship
    create_symlink ~/.dotfiles/wezterm ~/.config/wezterm

[group('chores')]
backup-shortcuts:
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > ~/.dotfiles/gnome/shortcuts/media-keys.txt
    dconf dump /org/gnome/shell/keybindings/ > ~/.dotfiles/gnome/shortcuts/shell-keys.txt
    dconf dump /org/gnome/desktop/wm/keybindings/ > ~/.dotfiles/gnome/shortcuts/wm-keys.txt
    dconf dump /org/gnome/mutter/keybindings/ > ~/.dotfiles/gnome/shortcuts/mutter-keys.txt
    dconf dump /org/gnome/mutter/wayland/keybindings/ > ~/.dotfiles/gnome/shortcuts/mutter-wayland-keys.txt

[group('chores')]
enable-shortcuts:
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/.dotfiles/gnome/shortcuts/media-keys.txt
    dconf load /org/gnome/shell/keybindings/ < ~/.dotfiles/gnome/shortcuts/shell-keys.txt
    dconf load /org/gnome/desktop/wm/keybindings/ < ~/.dotfiles/gnome/shortcuts/wm-keys.txt
    dconf load /org/gnome/mutter/keybindings/ < ~/.dotfiles/gnome/shortcuts/mutter-keys.txt
    dconf load /org/gnome/mutter/wayland/keybindings/ < ~/.dotfiles/gnome/shortcuts/mutter-wayland-keys.txt

[group('chores')]
enable-on-startup-script:
    mkdir -p ~/.config/autostart
    cp ~/.dotfiles/scripts/templates/on_startup.desktop ~/.config/autostart/

