set shell := ["fish", "-c"]

# create all config symlinks from the repo
symlinks:
    ~/.dotfiles/scripts/setup/symlink-dotfiles.sh

# enable docker, postgres, redis services
enable-services:
    sudo systemctl enable --now docker.service
    sudo systemctl enable --now postgresql.service
    sudo systemctl enable --now redis.service

# install on_startup autostart entry
enable-autostart:
    mkdir -p ~/.config/autostart
    cp ~/.dotfiles/scripts/setup/templates/on_startup.desktop ~/.config/autostart/

# remap trackball buttons
remap-trackball:
    ~/.dotfiles/scripts/desktop/remap_trackball.sh
