set shell := ["fish", "-c"]

# set fish as default shell and install fisher + plugins
setup:
    ~/.dotfiles/scripts/setup/setup-fish.sh

# set fish as the default shell
set-default-shell:
    chsh -s /usr/bin/fish

# install fisher and update plugins
install-fisher:
    fish -c 'if not functions -q fisher; curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher; end; fisher update'
