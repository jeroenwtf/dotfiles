thefuck --alias | source

source $HOME/.dotfiles/fish/functions/aliases.fish

# Makes npm work or something
function nvm
    bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

set -x NVM_DIR ~/.nvm
nvm use default --silent

# Removes fish greeting
set -g -x fish_greeting ''

# Spacefish options
set SPACEFISH_PROMPT_ORDER time user dir host git pyenv exec_time line_sep battery jobs exit_code char

set PATH /home/jeroen/.rvm/bin $PATH
rvm default
