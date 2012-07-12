" Pathogen support
filetype off
runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()
syntax on
filetype plugin indent on

set ruler
set modeline
set ttyfast
set hidden
set laststatus=2

" even quicker way to escape -- double j to get out of edit mode
inoremap jj <ESC>

let mapleader = ","

map ,v :tabedit $MYVIMRC<cr>         " edit my .vimrc file in a split
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif

set nocompatible
syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands

"" Whitespace
set wrap                        " visual wrapping
set linebreak                   " only wrap at good places (see breakat)
let &showbreak='> '             " show on beginning of linebreak lines
set expandtab                   " use spaces, not tabs
set scrolloff=5
set ts=4
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start  " backspace through everything in insert mode
nmap <leader>c :set colorcolumn=85<CR>

nmap <leader>l :set list!<CR>
set listchars=tab:▸\ ,eol:¬
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter
set showmatch
" leader-space to remove annoying highlighting
nnoremap <leader><space> :noh<cr>

" tab to find other end of parenthesis
nnoremap <tab> %
vnoremap <tab> %

"" macro -- change working directory
nnoremap <leader>h :cd ~/Dropbox/Personal/notes<CR>:pwd<CR>
nnoremap <leader>w :cd ~/Dropbox/Ning/notes<CR>:pwd<CR>

"" working with windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
nnoremap <leader>w <C-w>v<C-w>l

"" line numbers
set number
highlight LineNr cterm=NONE ctermfg=LightGrey ctermbg=DarkGrey  guifg=LightGrey guibg=DarkGrey 
command! -nargs=* Wrap set wrap linebreak nolist
nmap <C-N><C-N> :set invnumber<CR>
nmap <leader>n :set invnumber!<CR>
nmap <leader>r :set relativenumber!<CR>

"" use par for formatting
set formatprg=par\ -rq

"" when wrapping paragraphs, don't want to jump lines
nnoremap j gj
nnoremap k gk
nnoremap 0 g0
nnoremap $ g$
vnoremap j gj
vnoremap k gk
vnoremap 0 g0
vnoremap $ g$
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

map <leader>h :syntax off<cr>         " edit my .vimrc file in a split

nmap <silent> <leader>s :set spell!<CR>
set spelllang=en_us

colorscheme default 

"" nice little underline utility
"" from http://stevelosh.com/blog/2010/09/coming-home-to-vim/
nnoremap <leader>= yypVr=

" autosave on lost focus -- nice
" doesn't work in TTY mode, gvim only, all the more reason to use gvim more often
au FocusLost * :wa

" Hook for ack -- nice
nnoremap <leader>a :Ack<CR>
