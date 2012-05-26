set ruler
set hlsearch
set incsearch
set modeline
set ttyfast

let mapleader = ","

map ,v :tabedit $MYVIMRC<cr>         " edit my .vimrc file in a split
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif

set nocompatible
syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set wrap                        " visual wrapping
set linebreak                   " only wrap at good places (see breakat)
let &showbreak='> '             " show on beginning of linebreak lines
set expandtab                   " use spaces, not tabs
set ts=4
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start  " backspace through everything in insert mode

nmap <leader>l :set list!<CR>
set listchars=tab:▸\ ,eol:¬
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

"" macro -- change working directory
nnoremap <leader>h :cd ~/Dropbox/Personal/notes<CR>:pwd<CR>
nnoremap <leader>w :cd ~/Dropbox/Ning/notes<CR>:pwd<CR>

"" working with windows
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

"" line numbers
set number
highlight LineNr cterm=NONE ctermfg=LightGrey ctermbg=DarkGrey  guifg=LightGrey guibg=DarkGrey 
command! -nargs=* Wrap set wrap linebreak nolist
nmap <C-N><C-N> :set invnumber<CR>
nmap <leader>n :set invnumber<CR>

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
