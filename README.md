This is my .dotfiles repo. Still WIP but adding stuff from time to time.

# Things to do

Create symlinks for the configs.

```
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/fish ~/.config/fish
ln -s ~/.dotfiles/nvim ~/.config/nvim
ln -s ~/.dotfiles/mise ~/.config/mise
```

Create a `.gitconfig.local` file with the user name and email like the following:

```
[user]
  name = Jeroen van Meerendonk
  email = hola@jeroen.wtf
```

Install all the packages from `pacman`, `aur` and `snap`.

```
sudo pacman -S --needed - < pacman.pkgs
yay -S --needed - < aur.pkgs

sudo systemctl enable --now snapd.socket
sudo systemctl enable --now snapd.apparmor.service
# Now reboot...
xargs -a snap.pkgs sudo snap install
sudo snap set core experimental.refresh-app-awareness=true
```

Install `node`, `npm` and `gnome-extensions-cli` before continuing.

```
mise use -g node
pipx install gnome-extensions-cli --system-site-packages
```

And then...

```
xargs -a npm.pkgs npm install -g
xargs -a gnome.pkgs gext install
```

Make `fish` your default shell.

```
chsh -s /usr/bin/fish
```

Install `fisher` and its plugins.

```
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher update
```

Enable services.

```
sudo systemctl enable --now docker.service
sudo systemctl enable --now postgresql.service
sudo systemctl enable --now redis.service
```

Cast the screenshots into the fire.

```
ln -s /dev/null ~/Pictures/Screenshots
```
