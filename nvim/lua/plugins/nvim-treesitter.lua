return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  opts = {
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'ruby' },
    },
    autotag = true,
    indent = {
      enable = true,
      disable = { 'ruby' },
    },
  },
  init = function()
    local ensureInstalled = {
      'astro',
      'bash',
      'c',
      'css',
      'diff',
      'embedded_template',
      'fish',
      'git_config',
      'gitcommit',
      'html',
      'javascript',
      'just',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'rasi',
      'ruby',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
    }
    local alreadyInstalled = require('nvim-treesitter.config').get_installed()
    local parsersToInstall = vim.iter(ensureInstalled)
        :filter(function(parser)
          return not vim.tbl_contains(alreadyInstalled, parser)
        end)
        :totable()
    require('nvim-treesitter').install(parsersToInstall)

    vim.api.nvim_create_autocmd('FileType', {
      callback = function()
        -- Enable treesitter highlighting and disable regex syntax
        pcall(vim.treesitter.start)
        -- Enable treesitter-based indentation
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
    -- ...
  end,
}
