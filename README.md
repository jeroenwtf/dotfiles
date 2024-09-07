This is my .dotfiles repo. Still WIP but adding stuff from time to time.

# Things to do

## Create symlinks

```
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/fish ~/.config/fish
ln -s ~/.dotfiles/nvim ~/.config/nvim
```

Create a `.gitconfig.local` file with the user name and email like the following:

```
[user]
  name = Jeroen van Meerendonk
  email = hola@jeroen.wtf
```

## Install all the packages

```
sudo pacman -S --needed - < pacman.pkgs
yay -S --needed - < aur.pkgs
sudo snap install - < snap.pkgs
```

Install `node` and `npm` before continuing.

```
mise use -g node
```

And then...

```
npm install --global - < npm.pkgs
```

Make `fish` your default shell.

```
chsh -s /usr/bin/fish
```

Enable services.

```
sudo systemctl enable --now postgresql.service
sudo systemctl enable --now redis.service
```

Install `fisher` plugins.

```
fisher update
```

Some extra stuff.

```
sudo snap set core experimental.refresh-app-awareness=true
```
