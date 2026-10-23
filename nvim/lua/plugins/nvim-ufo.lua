return {
  'kevinhwang91/nvim-ufo',
  dependencies = 'kevinhwang91/promise-async',
  init = function()
    -- Start with all folds open, so they can be closed with zc
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    -- Show fold indicators next to the line numbers, sized to fit nested folds
    vim.o.foldcolumn = 'auto:9'
  end,
  opts = {
    provider_selector = function()
      return 'indent'
    end,
  },
}
