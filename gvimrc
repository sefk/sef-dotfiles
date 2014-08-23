" Font
set guifont=Menlo:h12
set antialias

" height of screen
set lines=50

" Change colorscheme -- doesn't look good on xterm-color, but looks mighty
" nice in macvim.
colorscheme murphy
let g:airline_theme='luna'

" use the system clipboard for copy/pasting
set clipboard=unnamed

" autosave on change focus. unnamed files won't be written. doesn't work in TTY mode.
au FocusLost * silent! wa

" Wildmenu on gvim is cool
set wildchar=<Tab> wildmenu wildmode=full
