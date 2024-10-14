source ~/.dotfiles/fish/aliases.fish

if test -f ~/.dotfiles/fish/secrets.fish
  source ~/.dotfiles/fish/secrets.fish
end

set -g -x fish_greeting '' # Removes fish greeting
set XDG_CONFIG_HOME ~/.config
set NODE_OPTIONS "--max-old-space-size=4096" # node memory
set PGUSER "postgres"
set EDITOR "nvim"

# PATH
set PATH ~/.npm-global/bin $PATH
set PATH ~/.npm/bin $PATH
set PATH ~/.cargo/bin $PATH
set PATH ~/.local/bin $PATH

# Sources
mise activate fish | source
thefuck --alias | source
starship init fish | source
