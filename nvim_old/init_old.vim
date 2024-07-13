call plug#begin('~/.vim/plugged')

" Plug 'monsonjeremy/onedark.nvim'
Plug 'sainnhe/gruvbox-material'
Plug 'editorconfig/editorconfig-vim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'jose-elias-alvarez/null-ls.nvim'

Plug 'nvim-tree/nvim-web-devicons' " optional, for file icons
Plug 'nvim-tree/nvim-tree.lua'

Plug 'rafamadriz/friendly-snippets'

Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'numToStr/Comment.nvim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'famiu/bufdelete.nvim'

call plug#end()

if has('termguicolors')
  set termguicolors
endif
set background=dark
colorscheme gruvbox-material

set clipboard+=unnamedplus
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set cursorline      " highlight current line
set nohlsearch      " No more highlighted text after search
set nowrap
set hid             " Allows hiding buffers, makes it faster
set ignorecase      " Make searching case insensitive
set list listchars=tab:>-,trail:.,extends:>
set mouse=a " Enable mouse in all in all modes
set number          " show line number
set scrolloff=10     " Minimal number of screen lines to keep above and below the cursor
set sidescrolloff=5    " Same but horizontally
set showmatch       " highlight matching brace
set smartcase       " ... unless the query has capital letters.
set completeopt=menu,menuone,noselect

" 80 column warning
"let &colorcolumn="80"

" Lualine
lua << EOF
require('lualine').setup {
  options = {
    theme = 'gruvbox-material',
  },
}
require("bufferline").setup()
require("gitsigns").setup()

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    "javascript",
    "typescript",
    "tsx",
    "yaml",
    "fish",
    "json",
    "html",
    "ruby",
    "scss",
    "astro",
    "markdown",
    "prisma",
  },
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

require('telescope').setup {
  defaults = {
    file_ignore_patterns = { "node_modules", ".git/" },
  },
  pickers = {
    find_files = {
      hidden = true,
    }
  },
  extensions = {
    file_browser = {
      grouped = true,
      sorting_strategy = 'ascending',
    },
  },
}

require("telescope").load_extension "file_browser"

require('Comment').setup()

local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "tsserver", "eslint", "tailwindcss", "astro", "prismals" },
}

local nvim_lsp = require "lspconfig"
nvim_lsp.astro.setup {}
nvim_lsp.prismals.setup {}
nvim_lsp.tailwindcss.setup {}
nvim_lsp.eslint.setup {}
nvim_lsp.tsserver.setup {
  capabilities = capabilities,
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "typescript.tsx" },
  cmd = { "typescript-language-server", "--stdio" },
  on_attach = function()
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, {buffer=0})
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {buffer=0})
    vim.keymap.set('n', '<leader>dl', '<cmd>Telescope diagnostics<cr>', {buffer=0})
    vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, {buffer=0})
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {buffer=0})
  end
}

vim.opt.completeopt={"menu", "menuone", "noselect"}

-- Set up nvim-cmp.
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
})

local null_ls = require('null-ls')
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.eslint_d,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.formatting.prettierd.with({
      -- only_local = "node_modules/.bin",
      extra_filetypes = { "prisma" },
      condition = function(utils)
        return utils.root_has_file({ ".prettierrc.json" })
      end,
    }),
  },
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 10000 })
        end,
      })
    end
  end,
})

require("indent_blankline").setup {
  show_current_context = true,
  show_current_context_start = true,
}

require("toggleterm").setup {
  open_mapping = [[<leader>\]],
  direction = 'float',
  float_opts = {
    border = 'curved',
  },
}

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup {
    update_focused_file = {
    enable = true,
  },
}

require("luasnip.loaders.from_vscode").lazy_load()

local luasnip = require('luasnip')
luasnip.filetype_extend("ruby", {"rails"})
luasnip.filetype_extend('javascript', { 'javascriptreact' })

EOF

let mapleader = "\<Space>"

" Get off my lawn
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

" Relative numbering
function! NumberToggle()
  if(&relativenumber == 1)
    set nornu
    set number
  else
    set rnu
  endif
endfunc

" Toggle between normal and relative numbering.
nnoremap <leader>l :call NumberToggle()<cr>
nnoremap <leader>t <cmd>Telescope find_files<cr>
nnoremap <leader>f <cmd>Telescope live_grep<cr>
nnoremap <leader><tab> <cmd>Telescope buffers<cr>
nnoremap <leader>w :Bdelete<cr>
" Close all buffers
nnoremap <leader>W :%bd<cr>
" nnoremap <leader>e :Explore<cr>
nnoremap <leader>e :Telescope file_browser path=%:p:h<cr>
nnoremap <leader>[ :BufferLineCyclePrev<cr>
nnoremap <leader>] :BufferLineCycleNext<cr>
nnoremap <leader>p :let @+=expand("%")<cr>
nnoremap <leader>s :NvimTreeFindFileToggle<cr>
nnoremap <leader>a :NvimTreeFocus<cr>
" Prevents yanking when pasting something over
vnoremap p "_dP

" settings for njk
au BufRead,BufNewFile *.njk,*.hbs set ft=html
autocmd BufRead,BufEnter *.astro set filetype=astro
autocmd BufRead,BufEnter *.mdx set filetype=markdown
