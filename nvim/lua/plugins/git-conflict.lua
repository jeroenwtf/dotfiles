return {
  'akinsho/git-conflict.nvim',
  version = '*',
  config = function()
    require('git-conflict').setup {
      default_mappings = false,
      default_commands = true,
      disable_diagnostics = false,
      list_opener = 'copen',
      highlights = {
        incoming = 'DiffAdd',
        current = 'DiffText',
      },
      debug = false,
    }

    vim.keymap.set('n', 'xo', '<Plug>(git-conflict-ours)')
    vim.keymap.set('n', 'xt', '<Plug>(git-conflict-theirs)')
    vim.keymap.set('n', 'xb', '<Plug>(git-conflict-both)')
    vim.keymap.set('n', 'x0', '<Plug>(git-conflict-none)')
    vim.keymap.set('n', 'xp', '<Plug>(git-conflict-prev-conflict)')
    vim.keymap.set('n', 'xn', '<Plug>(git-conflict-next-conflict)')
  end,
}
