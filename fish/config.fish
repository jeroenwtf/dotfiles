thefuck --alias | source

source $HOME/.dotfiles/fish/functions/aliases.fish

# Makes npm work or something
set PATH /home/jeroen/.nvm/versions/node/v14.16.0/bin $PATH

# Removes fish greeting
set -g -x fish_greeting ''

# Spacefish options
set SPACEFISH_PROMPT_ORDER time user dir host git pyenv exec_time line_sep battery jobs exit_code char
