return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
    },
    lazygit = {
      enabled = true,
    },
    styles = {
      lazygit = {
        border = "hpad",
        relative = "editor",
      },
    },
  },
  keys = {
    { '<leader>w', function() Snacks.bufdelete() end,     desc = 'Close current buffer' },
    { '<leader>W', function() Snacks.bufdelete.all() end, desc = 'Close all buffers' },
    { '<leader>g', function() Snacks.lazygit() end,       desc = 'Open lazy[g]it' }
  },
  init = function()
    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
      pattern = { '*lazygit*' },
      group = vim.api.nvim_create_augroup('git_refresh_neotree', { clear = true }),
      callback = function()
        require('neo-tree.sources.filesystem.commands').refresh(require('neo-tree.sources.manager').get_state 'filesystem')
      end,
    })
  end
}
