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
map("n", "<leader>@", ":vsplit<CR>", { silent = true })
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

-- Format options toggle (on <leader>fa/<leader>fA since claudecode.nvim held
-- <leader>a; the plugin is gone but the muscle memory is not)
map("n", "<leader>fa", ":set formatoptions-=a<CR>")
map("n", "<leader>fA", ":set formatoptions+=a<CR>")

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

-- Markdown preview via glow, in its own tab. Replaces the in-buffer markdown
-- rendering plugins, which garbled the screen over ssh/mosh/herdr.
-- Uses `tabnew` (a fresh empty buffer) rather than `vsplit` -- jobstart's
-- terminal takes over the *current* buffer, which after a plain split is still
-- the markdown file. Full width also keeps glow from hard-wrapping tables.
map("n", "<leader>mp", function()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("glow: buffer has no file", vim.log.levels.WARN)
    return
  end
  vim.cmd("silent! write")
  vim.cmd("tabnew")
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = false
  vim.wo[win].list = false
  vim.wo[win].spell = false
  local width = math.max(40, vim.api.nvim_win_get_width(win) - 2)
  vim.fn.jobstart({ "glow", "-w", tostring(width), "-p", file }, {
    term = true,
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Preview markdown with glow" })
