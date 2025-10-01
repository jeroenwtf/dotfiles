#---
# description: Install all sorts of packages
#---

start_task "Install pacman packages"
sudo pacman -S --needed - < packages/pacman.list
end_task

start_task "Install yay packages"
yay -S --needed --noconfirm - < packages/aur.list
end_task

start_task "Install mise tools"
mise use -g usage
mise install
end_task

start_task "Install gnome extensions"
pipx install gnome-extensions-cli --system-site-packages

while IFS= read -r extension; do
	gext install "$extension"
done < packages/gnome.list
end_task

