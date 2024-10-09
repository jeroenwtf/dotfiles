return {
  'stevearc/conform.nvim',
  lazy = false,
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        -- timeout_ms = 1500,
        lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
      }
    end,
    formatters_by_ft = {
      css = { 'prettierd' },
      javascript = { 'prettierd' },
      lua = { 'stylua' },
      -- ruby = { 'standardrb' },
    },
  },
}
