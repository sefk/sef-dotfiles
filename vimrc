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
" no, this is dumb
" inoremap jj <ESC>

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

"" working with windows - movement
map <leader>h :wincmd h<CR>
map <leader>j :wincmd j<CR>
map <leader>k :wincmd k<CR>
map <leader>l :wincmd l<CR>

"" opening
map <leader>x :split<CR>
map <leader>2 :split<CR>
map <leader>y :vsplit<CR>

" current window
noremap <silent> ,cc :close<cr>
" close other window
noremap <silent> ,1 :wincmd j<cr>:close<cr>

" Move the cursor to the another window
noremap <silent> ,h :wincmd h<cr>
noremap <silent> ,j :wincmd j<cr>
noremap <silent> ,k :wincmd k<cr>
noremap <silent> ,l :wincmd l<cr>
map <leader>, :wincmd w<CR>

" Close the window above, below...
noremap <silent> ,cj :wincmd j<cr>:close<cr>
noremap <silent> ,ck :wincmd k<cr>:close<cr>
noremap <silent> ,ch :wincmd h<cr>:close<cr>
noremap <silent> ,cl :wincmd l<cr>:close<cr>

" Move the current window to the right of the main Vim window
noremap <silent> ,ml <C-W>L
noremap <silent> ,mk <C-W>K
noremap <silent> ,mh <C-W>H
noremap <silent> ,mj <C-W>J

nmap<leader>w :set wrap!<CR>

noremap ,` :%y<CR>

"" line numbers
set number
highlight LineNr cterm=NONE ctermfg=LightGrey ctermbg=DarkGrey  guifg=LightGrey guibg=DarkGrey 
command! -nargs=* Wrap set wrap linebreak nolist
nmap <leader>n :set invnumber!<CR>
nmap <leader>r :set relativenumber!<CR>

"" C-n through buffers
:nmap <C-n> :bnext<CR>

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

nmap <silent> <leader>s :set spell!<CR>
set spelllang=en_us

"" colorscheme clouds

"" nice little underline utility
"" from http://stevelosh.com/blog/2010/09/coming-home-to-vim/
nnoremap <leader>= yypVr=

" autosave on lost focus -- nice
" doesn't work in TTY mode, gvim only, all the more reason to use gvim more often
" Also causes a problem if the file doesn't have a name yet -- maybe way to 
" assign a temp filename?
au FocusLost * :wa

" Hook for ack -- nice
nnoremap <leader>a :Ack<CR>


" This was an attempt to make hanging paragraphs and bulleted lists
" work for editing markdown.  But it's too broad, and autoindent
" has a bunch of weird side effects, wrapping things you might not
" want to wrap
"
" if has('autocmd')
"    au BufRead,BufNewFile *.txt set ai tw=72 fo=atcn wm=0
"    au BufRead,BufNewFile *.md set ai tw=72 fo=atcn wm=0
" endif


" This will shade everything past a certain column with a grey background
" visual warning that things are too wide.  More annyoing than useful
" augroup vimrc_autocmds
"    autocmd BufEnter * highlight OverLength ctermbg=darkgrey guibg=#592929
"    autocmd BufEnter * match OverLength /\%74v.*/
" augroup END


" This maps ,c to turn on a warning column.  More annoying than useful
" and no easy way to turn off.
"
" nmap <leader>c :set colorcolumn=85<CR>


" MiniBufExpl
" http://www.vim.org/scripts/script.php?script_id=159

let $Tlist_Ctags_Cmd='/usr/local/bin/ctags'
map <leader>p :TlistToggle<CR>


"" CTRL-P
"" from this useful article: http://statico.github.com/vim.html

set runtimepath^=~/.vim/bundle/ctrlp.vim
:nmap ; :CtrlPBuffer<CR>

:let g:ctrlp_map = '<Leader>t'
:let g:ctrlp_match_window_bottom = 0
:let g:ctrlp_match_window_reversed = 0
:let g:ctrlp_custom_ignore = '\v\~$|\.(o|swp|pyc|wav|mp3|ogg|blend)$|(^|[/\\])\.(hg|git|bzr)($|[/\\])|__init__\.py'
:let g:ctrlp_working_path_mode = 0
:let g:ctrlp_dotfiles = 0
:let g:ctrlp_switch_buffer = 0
