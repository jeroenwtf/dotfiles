#---
# description: Setup fish shell and its extensions
#---

start_task "Set fish as default shell"
chsh -s /usr/bin/fish
end_task

start_task "Install fisher and plugins"
fish -c 'if not functions -q fisher; curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher; end; fisher update'
end_task
