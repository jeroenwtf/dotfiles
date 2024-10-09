return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        never_show = { '.git' },
      },
      use_libuv_file_watcher = true,
      follow_current_file = {
        enabled = true,
      },
    },
    sources = {
      'filesystem',
      'document_symbols',
      'git_status',
    },
  },
}
