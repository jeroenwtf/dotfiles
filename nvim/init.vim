call plug#begin('~/.vim/plugged')

Plug 'monsonjeremy/onedark.nvim'
Plug 'editorconfig/editorconfig-vim'
Plug 'nvim-lualine/lualine.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'liuchengxu/vim-which-key'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'terrortylor/nvim-comment'

call plug#end()

"syntax on
"let g:onedark_termcolors=16
"colorscheme onedark

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
set showmatch       " highlight matching brace
set smartcase       " ... unless the query has capital letters.

" 80 column warning
"let &colorcolumn="80"

" Lualine
lua << EOF
vim.opt.termguicolors = true
require('onedark').setup()
require('lualine').setup {
  options = {
    theme = 'onedark',
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
    enable = false,
    disable = {},
  },
  ensure_installed = {
    "javascript",
    "yaml",
    "fish",
    "json",
    "html",
    "ruby",
    "scss",
  },
}
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()

local nvim_lsp = require('lspconfig')
nvim_lsp.tsserver.setup = {}

require('nvim_comment').setup {
  line_mapping = "<C-_>"
}
EOF

colorscheme onedark

let mapleader = "\<Space>"
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>

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
nnoremap <leader>r :call NumberToggle()<cr>
nnoremap <leader>t <cmd>Telescope find_files<cr>
nnoremap <leader><tab> <cmd>Telescope buffers<cr>

" show hover doc
nnoremap <silent>K :Lspsaga hover_doc<CR>
inoremap <silent> <C-k> <Cmd>Lspsaga signature_help<CR>

