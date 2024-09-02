source $HOME/.dotfiles/fish/aliases.fish

set -g -x fish_greeting '' # Removes fish greeting
set XDG_CONFIG_HOME ~/.config
set NODE_OPTIONS "--max-old-space-size=4096" # node memory
set PGUSER "postgres"

# PATH
set PATH ~/.npm-global/bin $PATH
set PATH ~/.npm/bin $PATH
set PATH ~/.cargo/bin $PATH

# Sources
mise activate fish | source
thefuck --alias | source
starship init fish | source
