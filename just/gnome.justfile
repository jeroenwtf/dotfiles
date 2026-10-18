set shell := ["fish", "-c"]

# dump GNOME keyboard shortcuts to gnome/shortcuts/
backup-shortcuts:
    dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > ~/.dotfiles/gnome/shortcuts/media-keys.txt
    dconf dump /org/gnome/shell/keybindings/ > ~/.dotfiles/gnome/shortcuts/shell-keys.txt
    dconf dump /org/gnome/desktop/wm/keybindings/ > ~/.dotfiles/gnome/shortcuts/wm-keys.txt
    dconf dump /org/gnome/mutter/keybindings/ > ~/.dotfiles/gnome/shortcuts/mutter-keys.txt
    dconf dump /org/gnome/mutter/wayland/keybindings/ > ~/.dotfiles/gnome/shortcuts/mutter-wayland-keys.txt

# load GNOME keyboard shortcuts from gnome/shortcuts/
enable-shortcuts:
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < ~/.dotfiles/gnome/shortcuts/media-keys.txt
    dconf load /org/gnome/shell/keybindings/ < ~/.dotfiles/gnome/shortcuts/shell-keys.txt
    dconf load /org/gnome/desktop/wm/keybindings/ < ~/.dotfiles/gnome/shortcuts/wm-keys.txt
    dconf load /org/gnome/mutter/keybindings/ < ~/.dotfiles/gnome/shortcuts/mutter-keys.txt
    dconf load /org/gnome/mutter/wayland/keybindings/ < ~/.dotfiles/gnome/shortcuts/mutter-wayland-keys.txt
