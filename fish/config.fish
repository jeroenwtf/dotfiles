source ~/.dotfiles/fish/aliases.fish

if test -f ~/.dotfiles/fish/secrets.fish
  source ~/.dotfiles/fish/secrets.fish
end

set -g -x fish_greeting '' # Removes fish greeting
set XDG_CONFIG_HOME ~/.config
set XDG_CURRENT_DESKTOP GNOME
set NODE_OPTIONS "--max-old-space-size=4096" # node memory
set PGUSER "postgres"
set EDITOR "nvim"
set --export STARSHIP_CONFIG ~/.config/starship/starship.toml

# PATH
fish_add_path ~/.npm-global/bin
fish_add_path ~/.npm/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
# fish_add_path ~/.local/share/mise/shims

# Sources
mise activate fish | source
thefuck --alias | source
starship init fish | source
