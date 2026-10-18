set shell := ["fish", "-c"]

# install everything: pacman, aur, mise, gnome extensions
all: pacman aur mise extensions

# install packages from packages/pacman.list
pacman:
    sudo pacman -S --needed - < ~/.dotfiles/packages/pacman.list

# install packages from packages/aur.list via yay
aur:
    yay -S --needed --noconfirm - < ~/.dotfiles/packages/aur.list

# install runtimes and tools via mise
mise:
    mise use -g usage; and mise install

# install gnome extensions from packages/gnome.list
extensions:
    ~/.dotfiles/scripts/setup/install-gnome-extensions.sh
