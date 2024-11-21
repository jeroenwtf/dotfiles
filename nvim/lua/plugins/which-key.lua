return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    require('which-key').setup()

    -- Document existing key chains
    require('which-key').add {
      {
        { '<leader>a', group = '[A]i' },
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument' },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>o', group = '[O] .open-files' },
        { '<leader>x', group = '[X] Git conflict' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    }
  end,
}
