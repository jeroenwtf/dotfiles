return {
  'folke/tokyonight.nvim',
  priority = 1000,
  init = function()
    vim.cmd.colorscheme 'tokyonight-night'
    vim.cmd.hi 'Comment gui=none'
    -- Darker bg for folded blocks (tokyonight bg_dark) instead of default bg_highlight
    vim.cmd.hi 'Folded guibg=#16161e'
    -- Make fold column indicators stand out (tokyonight magenta)
    vim.cmd.hi 'FoldColumn guifg=#bb9af7'
  end,
}
