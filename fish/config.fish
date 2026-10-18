source ~/.dotfiles/fish/aliases.fish

if test -f ~/.dotfiles/fish/secrets.fish
  source ~/.dotfiles/fish/secrets.fish
end

set -gx fish_greeting '' # Removes fish greeting
set NODE_OPTIONS "--max-old-space-size=4097" # node memory - enabled again to test if it's still necessary
set PGUSER "postgres"
set -gx EDITOR nvim
set -x STARSHIP_CONFIG ~/.config/starship/starship.toml

# PATH
fish_add_path ~/.npm-global/bin
fish_add_path ~/.npm/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
fish_add_path ~/.rebbletool/rebbletool/bin

# Sources
if status is-interactive
  mise activate fish | source
  # atuin init fish | source
  atuin init fish | sed 's/-k up/up/' | source # Temporary hack fix
else
  mise activate fish --shims | source
end

thefuck --alias | source
starship init fish | source

# opencode
fish_add_path /home/jeroen/.opencode/bin

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
