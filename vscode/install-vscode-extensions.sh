#!/bin/bash

# execute command
# -------------------
# curl -s https://raw.githubusercontent.com/karaage0703/vscode-dotfiles/master/install-vscode-extensions.sh | /bin/bash

# Visual Studio Code :: Package list
pkglist=(
amandeepmittal.pug
bradlc.vscode-tailwindcss
dbaeumer.vscode-eslint
EditorConfig.EditorConfig
esbenp.prettier-vscode
karunamurti.haml
ms-vsliveshare.vsliveshare
rebornix.ruby
sianglim.slim
thibaudcolas.stylelint
waderyan.gitblame
wingrunr21.vscode-ruby
zhuangtongfa.material-theme
)

for i in ${pkglist[@]}; do
  codium --install-extension $i
done
