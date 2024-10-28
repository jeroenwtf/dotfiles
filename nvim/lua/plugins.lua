local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth',
  'petertriho/nvim-scrollbar',
  'windwp/nvim-ts-autotag',

  require 'plugins.comment',
  require 'plugins.conform',
  require 'plugins.git-conflict',
  require 'plugins.gitsigns',
  require 'plugins.gp',
  require 'plugins.lazygit',
  require 'plugins.menu',
  require 'plugins.mini',
  require 'plugins.neo-tree',
  require 'plugins.nvim-cmp',
  require 'plugins.nvim-lspconfig',
  require 'plugins.nvim-treesitter',
  require 'plugins.telescope',
  require 'plugins.todo-comments',
  require 'plugins.tokyonight',
  require 'plugins.which-key',
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
