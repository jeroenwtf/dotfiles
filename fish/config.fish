#eval (python -m virtualfish)
thefuck --alias | source

source $HOME/.dotfiles/fish/functions/aliases.fish
source $HOME/.dotfiles/fish/functions/private_aliases.fish

set -g -x fish_greeting ''

# Spacefish options
set SPACEFISH_PROMPT_ORDER time user dir host git pyenv exec_time line_sep battery jobs exit_code char
