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
Plug 'terrortylor/nvim-comment'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-eunuch'

call plug#end()

"syntax on
"let g:onedark_termcolors=16
"colorscheme onedark

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

require('nvim_comment').setup {
  line_mapping = "<C-_>"
}

local telescope = require('telescope')
telescope.setup {
  defaults = {
    layout_strategy = "vertical",
    file_ignore_patterns = { "node_modules" },
  },
  pickers = {
    find_files = {
      hidden = true,
    }
  }
}
EOF

let g:coc_global_extensions = ['coc-tsserver', 'coc-json', 'coc-stylelintplus']

if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/tailwindcss')
  let g:coc_global_extensions += ['coc-tailwindcss']
endif

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
nnoremap <leader>f <cmd>Telescope live_grep<cr>
nnoremap <leader><tab> <cmd>Telescope buffers<cr>
nnoremap <leader>w :bd<cr>
nnoremap <leader>e :Explore<cr>
nnoremap <leader>[ :BufferLineCyclePrev<cr>
nnoremap <leader>] :BufferLineCycleNext<cr>
nnoremap <leader>p :let @+=expand("%")<cr>
nnoremap <leader>P :CocCommand prettier.formatFile<cr>

" settings for njk
au BufRead,BufNewFile *.njk,*.hbs set ft=html
