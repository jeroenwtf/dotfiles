# Quick access
alias :fp 'cd ~/Desktop/Local/FP/src/qfpp'
alias :qweb 'cd ~/Desktop/Local/qnew'
alias :qcloud 'cd ~/Desktop/Local/FP/src/qcloud'
alias :qapi 'cd ~/Desktop/Local/FP/src/qapi'

# Quick config edits
# TODO: Add tmux?
# TODO: Add chunkwm?
function config
    if test (count $argv) -gt 0
        switch $argv[1]
        case vim
            nvim ~/.dotfiles/vim/init.vim
        case git
            nvim ~/.dotfiles/git/.gitconfig
        case fish
            nvim ~/.dotfiles/fish/config.fish
        case '*'
            echo Config file not listed.
        end
    else
        echo Need to specify a config.
    end
end
