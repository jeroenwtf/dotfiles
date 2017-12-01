eval (python -m virtualfish)
thefuck --alias | source

# Base16 Shell
if status --is-interactive
    eval sh $HOME/.config/base16-shell/scripts/base16-eighties.sh
end

source $HOME/.dotfiles/fish/functions/aliases.fish
source $HOME/.dotfiles/fish/functions/private_aliases.fish