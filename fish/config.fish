source ~/.dotfiles/fish/aliases.fish

if test -f ~/.dotfiles/fish/secrets.fish
  source ~/.dotfiles/fish/secrets.fish
end

set -gx fish_greeting '' # Removes fish greeting
set XDG_CONFIG_HOME ~/.config
set XDG_CURRENT_DESKTOP GNOME
# set NODE_OPTIONS "--max-old-space-size=4096" # node memory - disabled to test if it's still necessary
set PGUSER "postgres"
set EDITOR "nvim"
set -x STARSHIP_CONFIG ~/.config/starship/starship.toml

# PATH
fish_add_path ~/.npm-global/bin
fish_add_path ~/.npm/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
# fish_add_path ~/.local/share/mise/shims

# Sources
if status is-interactive
  mise activate fish | source
else
  mise activate fish --shims | source
end
thefuck --alias | source
starship init fish | source
