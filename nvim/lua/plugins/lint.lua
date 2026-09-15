return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Built-in `erb_lint` runs via `bundle exec`, which fails outside bundler projects.
      -- Use the mise-installed binary directly.
      lint.linters.erb_lint = {
        cmd = 'erb_lint',
        args = { '--format', 'compact' },
        stream = 'stdout',
        ignore_exitcode = true,
        parser = require('lint.parser').from_errorformat('%f:%l:%c: %m', {
          source = 'erb-lint',
          severity = vim.diagnostic.severity.WARN,
        }),
      }

      lint.linters_by_ft = {
        ruby = { 'rubocop' },
        eruby = { 'erb_lint' },
        javascript = { 'eslint' },
        javascriptreact = { 'eslint' },
        typescript = { 'eslint' },
        typescriptreact = { 'eslint' },
      }

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
  },
}
