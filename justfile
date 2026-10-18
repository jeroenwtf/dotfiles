set shell := ["fish", "-c"]

mod system 'just/system.justfile'
mod packages 'just/packages.justfile'
mod gnome 'just/gnome.justfile'
mod fish 'just/fish.justfile'

# full machine setup: symlinks -> packages -> shortcuts -> fish -> services -> autostart
setup:
    @just system symlinks

    @just packages all

    @just gnome enable-shortcuts

    @just fish setup

    @just system enable-services
    @just system enable-autostart

# regenerate gitignored fish secret files from ~/.secrets
secrets-pull:
    ~/.dotfiles/scripts/setup/secrets-pull.sh
