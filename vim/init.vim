" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
call plug#begin('~/.vim/plugged')

"Plug 'chriskempson/base16-vim'
Plug 'arcticicestudio/nord-vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'airblade/vim-gitgutter'
Plug 'mattn/emmet-vim'
Plug 'shougo/deoplete.nvim'
Plug 'bling/vim-bufferline'
Plug 'othree/html5.vim'
Plug 'matze/vim-move'
Plug 'hail2u/vim-css3-syntax'
Plug 'cakebaker/scss-syntax.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'django.vim'
Plug 'shawncplus/phpcomplete.vim'
Plug 'w0rp/ale'
Plug 'scrooloose/nerdcommenter'
Plug 'jremmen/vim-ripgrep'
Plug 'yggdroot/indentline'

call plug#end()

syntax on
colorscheme nord

set cursorline      " highlight current line
set showmatch       " highlight matching brace
set ignorecase      " Make searching case insensitive
set smartcase       " ... unless the query has capital letters.
set number          " show line number
set hid             " Allows hiding buffers, makes it faster
set list listchars=tab:>-,trail:.,extends:>
set mouse=a " Enable mouse in all in all modes

" 80 column warning
let &colorcolumn="80"

" PostCSS stuff
augroup filetypedetect
  au BufRead,BufNewFile *.css set filetype=scss
augroup END

" Airline
let g:airline_powerline_fonts = 1

" Bufferline
let g:bufferline_modified = '*'

" Deoplete
autocmd FileType css,sass,scss setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType php setlocal omnifunc=phpcomplete_extended#CompletePHP
let g:deoplete#enable_at_startup = 1

" Ctrlp config
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
if executable('ag')
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Ale linter
let g:ale_sign_error = 'x'
let g:ale_sign_warning = '!'
hi ALEErrorSign cterm=NONE ctermfg=red ctermbg=NONE
hi ALEWarningSign cterm=NONE ctermfg=yellow ctermbg=NONE

" Grepping with ripgrep
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif


" Remapping
map <c-b> :CtrlPBuffer<cr>
" nnoremap <C-J> <C-W><C-J>
" nnoremap <C-K> <C-W><C-K>
" nnoremap <C-L> <C-W><C-L>
" nnoremap <C-H> <C-W><C-H>

" Delete lines for realz, no yanking
nnoremap d "_d
vnoremap d "_d

" Move between buffers using TAB and SHIFT+TAB
nnoremap  <silent>   <tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bnext<CR>
nnoremap  <silent> <s-tab>  :if &modifiable && !&readonly && &modified <CR> :write<CR> :endif<CR>:bprevious<CR>

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
