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

[group('install packages')]
install-aur-packages:

[group('chores')]
install-gnome-extensions-cli:

[group('install packages')]
install-gnome-extensions:

[group('chores')]
install-mise-tools:

[group('fish')]
set-default-shell:

[group('fish')]
install-fisher-and-plugins:

[group('chores')]
symlink-dotfiles:

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

