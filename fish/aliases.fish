# Credits:
# Some stuff stolen from https://github.com/paulirish/dotfiles/blob/main/fish/aliases.fish

# mv, rm, cp
abbr mv 'mv -v'
abbr rm 'rm -v'
abbr cp 'cp -v'

# eza
alias ls='eza --classify=auto --color --group-directories-first --sort=extension -A'
alias la='eza --classify=auto --color --group-directories-first --sort=extension -a -l --octal-permissions --no-permissions'

# lazygit and lazydocker
alias lzg="lazygit"
alias lzd="lazydocker"
