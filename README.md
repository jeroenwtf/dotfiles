This is my .dotfiles repo. Still WIP but adding stuff from time to time.

# Things to do

## Create symlinks
```
ln -s ~/.dotfiles/git/.gitconfig ~/.gitconfig
ln -s ~/.dotfiles/kitty ~/.config/kitty
ln -s ~/.dotfiles/fish ~/.config/fish
ln -s ~/.dotfiles/nvim ~/.config/nvim
```

Create a `.gitconfig.local` file with the user name and email.

## Install RVM
```
curl -L get.rvm.io > rvm-install
bash < ./rvm-install
```

## Install everything together
One command for `pacman` stuff.
```
sudo pacman -S fish fisher starship thefuck nodejs npm diff-so-fancy spotify-launcher ripgrep xclip
```
Don't forget that you will have to install the Fisher plugins and the Hack patched font.

## Or separately

Install Fish
```
sudo pacman -S fish
```

Install Fisher
```
sudo pacman -S fisher
```

Install Fisher plugins
```
fisher install
```

Install Starship
```
sudo pacman -S starship
```

Install thefuck
```
sudo pacman -S thefuck
```

Install `node` and `npm`
```
sudo packman -S nodejs npm
nvm install node
```

Install Hack patched font:
```
yay -S ttf-hack-nerd
```

Install `diff-so-fancy`
```
sudo pacman -S diff-so-fancy
```

Install Spotify
```
sudo pacman -S spotify-launcher
```

Install Slack
```
yay -S slack-desktop
```

Install Ferdium
```
yay -S ferdium-bin
```

Install ripgrep
```
sudo pacman -S ripgrep
```

Install git-recent
```
npm install --global git-recent
```

Install xclip
```
sudo pacman -S xclip
```
