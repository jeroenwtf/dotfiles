return {
  'rachartier/tiny-inline-diagnostic.nvim',
  event = 'VeryLazy',
  priority = 1000,
  config = function()
    require('tiny-inline-diagnostic').setup {
      preset = 'simple',
      options = {
        show_source = true,
        add_messages = false,
        multiple_diag_under_cursor = true,
        multilines = {
          enabled = true,
        },
      },
      signs = {
        diag = '●',
      },
    }
  end,
}
