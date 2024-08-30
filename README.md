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
pacman -S --needed - < pacman.pkgs
yay -S --needed - < aur.pkgs
```

## Some leftovers

Install `node` and `npm`

```
mise use -g node
```

Install `git-recent`

```
npm install --global git-recent
```

Install node packages

```
# Language servers
npm install -g yaml-language-server
npm install -g @microsoft/compose-language-service
npm install -g @astrojs/language-server
- ts/js?

# Other daemons
npm install -g @fsouza/prettierd
```
