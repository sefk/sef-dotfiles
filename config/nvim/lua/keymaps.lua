local map = vim.keymap.set

-- jk to escape insert mode
map("i", "jk", "<Esc>")

-- Keep visual selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Navigate wrapped lines naturally
map({ "n", "v" }, "j", "gj")
map({ "n", "v" }, "k", "gk")
map({ "n", "v" }, "0", "g0")
map({ "n", "v" }, "$", "g$")
map({ "n", "v" }, "<Down>", "gj")
map({ "n", "v" }, "<Up>", "gk")
map("i", "<Down>", "<C-o>gj")
map("i", "<Up>", "<C-o>gk")

-- Toggle line numbers
map("n", "<C-L>", ":set invnu<CR>")

-- Q formats paragraph (no Ex mode)
map("n", "Q", "gwip", { silent = true })

-- Window management
map("n", "<leader>,", ":wincmd w<CR>")
map("n", "<leader>2", ":split<CR>", { silent = true })
map("n", "<leader>1", ":wincmd j<CR>:close<CR>", { silent = true })
map("n", "<leader>0", ":close<CR>", { silent = true })

-- Force save with sudo
vim.cmd("cmap w!! w !sudo tee > /dev/null %")

-- Spell
map("n", "<leader>ts", ":set spell!<CR>")
map("n", "<leader>z", "1z=")

-- Format paragraph
map("n", "<leader>q", "gqip")

-- Centered search
map("n", "n", "nzz$")
map("n", "N", "Nzz$")

-- Source / edit nvim config
map("n", "<leader>vs", ":source $MYVIMRC<CR>")
map("n", "<leader>ve", ":e $MYVIMRC<CR>")

-- Format entire file
map("n", "<leader>fef", ":normal! gg=G``<CR>")

-- Open file in same directory
map("n", "<leader>ew", ":e <C-R>=expand('%:h').'/'<CR>")
map("n", "<leader>es", ":sp <C-R>=expand('%:h').'/'<CR>")
map("n", "<leader>ev", ":vsp <C-R>=expand('%:h').'/'<CR>")
map("n", "<leader>et", ":tabe <C-R>=expand('%:h').'/'<CR>")

-- Underline current line with '='
map("n", "<leader>ul", ":t.<CR>Vr=", { silent = true })

-- Find merge conflict markers
map("n", "<leader>fc", "<ESC>/\\v^[<=>]{7}( .*|$)<CR>", { silent = true })

-- Toggle search highlight
map("n", "<leader><space>", ":set hlsearch! hlsearch?<CR>")

-- Substitute word under cursor
map("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/")

-- Paste from clipboard
map("n", "<leader>P", ":set paste<CR>:put  *<CR>:set nopaste<CR>")

-- Format options toggle
map("n", "<leader>a", ":set formatoptions-=a<CR>")
map("n", "<leader>A", ":set formatoptions+=a<CR>")

-- Tab management
map("n", "<leader>tt", ":tabnew<CR>")
map("n", "<leader>te", ":tabedit ")
map("n", "<leader>tc", ":tabclose<CR>")
map("n", "<leader>to", ":tabonly<CR>")
map("n", "<leader>tn", ":tabnext<CR>")
map("n", "<leader>tp", ":tabprevious<CR>")
map("n", "<leader>tf", ":tabfirst<CR>")
map("n", "<leader>tl", ":tablast<CR>")
map("n", "<leader>tm", ":tabmove ")

-- Ctrl+arrows to navigate / reorder tabs
map("n", "<C-Left>", ":tabprevious<CR>")
map("n", "<C-Right>", ":tabnext<CR>")
map("n", "<C-S-Left>", ":execute 'silent! tabmove ' . (tabpagenr()-2)<CR>", { silent = true })
map("n", "<C-S-Right>", ":execute 'silent! tabmove ' . tabpagenr()<CR>", { silent = true })

-- H/L to cycle tabs or buffers
vim.cmd([[
  function! MyNext()
    if exists('*tabpagenr') && tabpagenr('$') != 1
      normal gt
    else
      execute ":bnext"
    endif
  endfunction
  function! MyPrev()
    if exists('*tabpagenr') && tabpagenr('$') != '1'
      normal gT
    else
      execute ":bprev"
    endif
  endfunction
]])
map("n", "L", ":call MyNext()<CR>")
map("n", "H", ":call MyPrev()<CR>")
