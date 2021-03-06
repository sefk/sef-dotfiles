set nocompatible


"======================"
" Vundle configuration "
"======================"

filetype off
filetype plugin indent on

"" it all starts with the leader
let mapleader = ","


filetype plugin indent on


"" highlight current line
"" set cul

" Printing
set printheader=%=Page\ %N

" jk is an another way to escape -- wowza
imap jk <Esc>

" Keep visual blocks around
vnoremap < <gv
vnoremap > >gv

" Don't insert two spaces after period when joining / reformatting
set nojs

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
nnoremap <C-L> :set invnu<CR>

" never want to enter Ex mode -- replace w/ format paragraph
nnoremap <silent> Q gwip

" Window
noremap <leader>, :wincmd w<CR>
noremap <silent> <leader>2 :split<CR>
noremap <silent> <leader>1 :wincmd j<cr>:close<cr>
noremap <silent> <leader>0 :close<cr>

" Force saving files that require root permission
cmap w!! w !sudo tee > /dev/null %

" Misc useful leader commands
nnoremap <leader>ts :set spell!<CR>
nnoremap <leader>z 1z=
nnoremap <leader>fp !ipfmt 72<CR>
nnoremap <leader>q gqip

" Centering the search next/search previous$
nmap n nzz$
nmap N Nzz$

set hidden                        " allow unsaved buffers to exist (duh)
set linebreak

set nocompatible      " Use vim, no vi defaults
set number            " Show line numbers
set ruler             " Show line and column number
syntax enable         " Turn on syntax highlighting allowing local overrides
set encoding=utf-8    " Set default encoding to UTF-8

set wrap                          " by default wrap lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set softtabstop=2
set expandtab                     " use spaces, not tabs
set list                          " Show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode

" List chars
set listchars=""                  " Reset the listchars
set listchars=tab:\ \             " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " The character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " The character to show in the last column when wrap is
                                  " off and the line continues beyond the left of the screen


""
"" Searching
""

set hlsearch    " highlight matches
set incsearch   " incremental searching
set ignorecase  " searches are case insensitive...
set smartcase   " ... unless they contain at least one capital letter


""
"" Backup and swap files
""

set backupdir^=~/.vim/_backup//    " where to put backup files.
set directory^=~/.vim/_temp//      " where to put swap files.


" crtl n/p cycle through buffers in current tab, which we don't want
" if we're using one tab per buffer
" :nnoremap <C-n> :bnext!<CR>:redraw<CR>:ls<CR>
" :nnoremap <C-p> :bprevious!<CR>:redraw<CR>:ls<CR>
" map <leader>b :ls<CR>

" useful doohickey copied from
" http://stackoverflow.com/questions/53664/how-to-effectively-work-with-multiple-files-in-vim
" Movement between tabs OR buffers



nnoremap L :call MyNext()<CR>
nnoremap H :call MyPrev()<CR>

" MyNext() and MyPrev(): Movement between tabs OR buffers
function! MyNext()
    if exists( '*tabpagenr' ) && tabpagenr('$') != 1
        " Tab support && tabs open
        normal gt
    else
        " No tab support, or no tabs open
        execute ":bnext"
    endif
endfunction
function! MyPrev()
    if exists( '*tabpagenr' ) && tabpagenr('$') != '1'
        " Tab support && tabs open
        normal gT
    else
        " No tab support, or no tabs open
        execute ":bprev"
    endif
endfunction

" Use the system clipboard instead of just the VIM one
" noremap y "*y
" noremap yy "*Y
" noremap p "*p
" noremap P "*P
" noremap dd "*dd
" noremap D "*D

" use system clipboard with mac in terminal mode
" set clipboard=unnamed

" Preserve indentation while pasting text from the OS X clipboard
noremap <leader>P :set paste<CR>:put  *<CR>:set nopaste<CR>


noremap <leader>vs :source $MYVIMRC<cr>
noremap <leader>ve :e ~/.vimrc<cr>
autocmd bufwritepost .vimrc source $MYVIMRC

" Text mode
autocmd BufRead,BufNewFile *.txt set wrap linebreak nolist


"
" Cribbed from Janus
"

" format the entire file
nnoremap <leader>fef :normal! gg=G``<CR>

" Some helpers to edit mode
" http://vimcasts.org/e/14
nnoremap <leader>ew :e <C-R>=expand('%:h').'/'<cr>
nnoremap <leader>es :sp <C-R>=expand('%:h').'/'<cr>
nnoremap <leader>ev :vsp <C-R>=expand('%:h').'/'<cr>
nnoremap <leader>et :tabe <C-R>=expand('%:h').'/'<cr>

" Underline the current line with '='
nnoremap <silent> <leader>ul :t.<CR>Vr=

" find merge conflict markers
nnoremap <silent> <leader>fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

" ,s turns off highlight marks
nnoremap <leader><space> :set hlsearch! hlsearch?<CR>

if has("autocmd")
    " In Makefiles, use real tabs, not tabs expanded to spaces
    au FileType make setlocal noexpandtab

    au BufRead,BufNewFile *.jbconfig setf borg

    " Make sure all mardown files have the correct filetype set and setup wrapping
    au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown
    if !exists("g:disable_markdown_autostyle")
        au FileType markdown setlocal wrap linebreak textwidth=72 nolist
    endif

    " Treat JSON files like JavaScript
    au BufNewFile,BufRead *.json set ft=javascript

    " make Python follow PEP8 for whitespace ( http://www.python.org/dev/peps/pep-0008/ )
    " au FileType python setlocal softtabstop=4 tabstop=4 shiftwidth=4

    " Remember last location in file, but not for commit messages.
    " see :help last-position-jump
    au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
      \| exe "normal! g`\"" | endif

endif

"
" Specific Formats
"

set noautoindent
noremap <leader>a :set formatoptions-=a<CR>
noremap <leader>A :set formatoptions+=a<CR>

" good for google style
set formatoptions=croqlj

" substitute for whatevers under cursor
nnoremap <leader>s :%s/\<<C-r><C-w>\>/

" text modes: wrap nicely
au BufEnter *.txt,*.text setlocal wrap linebreak nolist textwidth=0 wrapmargin=5

" markdown
" au BufEnter *.Markdown,*.md setlocal wrap linebreak nolist textwidth=0 wrapmargin=5
" nnoremap <leader>m :w<cr>:silent !open -a "Marked 2.app" '%:p'<cr>:redraw!<cr>
" let g:vim_markdown_folding_disabled=1

" text modes: wrap nicely
au BufEnter *.h,*.c,*.cc,*.cpp setlocal autoindent

"
" Plugins
"

" nerdtree
noremap <C-n> :NERDTreeToggle<CR>

" ack
let g:ackprg = 'ag --nogroup --nocolor --column'     " use silver searcher instead of ack

" Tab mapping
map <leader>tt :tabnew<cr>
map <leader>te :tabedit
map <leader>tc :tabclose<cr>
map <leader>to :tabonly<cr>
map <leader>tn :tabnext<cr>
map <leader>tp :tabprevious<cr>
map <leader>tf :tabfirst<cr>
map <leader>tl :tablast<cr>
map <leader>tm :tabmove

" useful tab commands: control to select, control+shift to move
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <silent> <C-S-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <C-S-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>

" mouse scrolling in the terminal!!
set mouse=a

" Save when losing focus
au BufLeave,FocusLost * :silent! wall
set autoread autowrite


" COLORS

" csv

hi CSVColumnEven ctermbg=4 guibg=DarkBlue
hi CSVColumnOdd  ctermbg=5 guibg=DarkMagenta
hi CSVColumnHeaderEven term=bold ctermbg=4 guibg=DarkBlue
hi CSVColumnHeaderOdd  term=bold ctermbg=5 guibg=DarkMagenta

hi SpellBad ctermbg=136



" STATUSLINE

set laststatus=2
" set statusline=\ %f\ %{fugitive#statusline()}\ %m%r%h%w\ %=%({%{&ff}\|%{(&fenc==\"\"?&enc:&fenc).((exists(\"+bomb\")\ &&\ &bomb)?\",B\":\"\")}%k\|%Y}%)\ %([%l,%v][%p%%]\ %)
hi StatusLine ctermbg=black ctermfg=DarkYellow
hi StatusLineNC ctermbg=black ctermfg=gray
hi VertSplit ctermbg=black ctermfg=DarkYellow
set fillchars+=vert:\ 

