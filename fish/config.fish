thefuck --alias | source

source $HOME/.dotfiles/fish/aliases.fish

# Makes npm work or something
#function nvm
#    bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
#end

# Removes fish greeting
set -g -x fish_greeting ''

#set PATH /home/jeroen/.rvm/bin $PATH
#rvm default

# node memory
set NODE_OPTIONS "--max-old-space-size=4096"
set PATH ~/.npm-global/bin $PATH
set PATH ~/.cargo/bin $PATH
set XDG_CONFIG_HOME ~/.config

# postres
set PGUSER "postgres"

#rbenv
#status --is-interactive; and ~/.rbenv/bin/rbenv init - fish | source

set -x PATH $HOME/.rbenv/bin $PATH
rbenv init - | source

starship init fish | source
