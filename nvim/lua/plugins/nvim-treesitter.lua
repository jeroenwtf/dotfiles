return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  opts = {
    ensure_installed = {
      'astro',
      'bash',
      'c',
      'diff',
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
    },
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
  config = function(_, opts)
    require('nvim-treesitter.install').prefer_git = true
    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)
  end,
}
