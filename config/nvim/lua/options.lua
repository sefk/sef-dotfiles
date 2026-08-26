-- Leader (set before lazy loads plugins)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

local opt = vim.opt

-- Display
opt.number = true
opt.ruler = true
opt.wrap = true
opt.linebreak = true
opt.list = true
opt.listchars = { tab = "  ", trail = "·", extends = ">", precedes = "<" }
opt.laststatus = 2
opt.fillchars:append({ vert = " " })

-- Never conceal. Concealment changes the byte<->column mapping mid-line, which
-- is the main way in-buffer markdown rendering garbled the display remotely.
-- Set explicitly so a plugin default can't quietly turn it back on.
opt.conceallevel = 0
opt.concealcursor = ""

-- Editing
opt.hidden = true
opt.backspace = { "indent", "eol", "start" }
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.autoindent = false
opt.formatoptions = "croqlj"
opt.joinspaces = false  -- don't insert two spaces after period

-- Encoding
opt.encoding = "utf-8"

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Mouse
opt.mouse = "a"

-- Auto-save
opt.autoread = true
opt.autowrite = true

-- Spell
opt.spelllang = "en"
opt.spellfile = vim.fn.expand("~/.vim/spell/en.utf-8.add")

-- Backup / swap
opt.backupdir:prepend(vim.fn.expand("~/.vim/_backup//"))
opt.directory:prepend(vim.fn.expand("~/.vim/_temp//"))

-- Filetype-specific autocommands
local au = vim.api.nvim_create_autocmd

-- Makefiles: real tabs
au("FileType", {
  pattern = "make",
  callback = function() vim.opt_local.expandtab = false end,
})

-- .jbconfig -> borg filetype
au({ "BufRead", "BufNewFile" }, {
  pattern = "*.jbconfig",
  callback = function() vim.bo.filetype = "borg" end,
})

-- Markdown: soft wrap (no hard line breaks) + spell check
au("FileType", {
  pattern = { "markdown", "html" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.textwidth = 0
    vim.opt_local.list = true
    vim.opt_local.listchars = { trail = "·" }
    vim.opt_local.formatoptions:remove("t")
    vim.opt_local.spell = true
  end,
})

-- JSON -> javascript filetype
au({ "BufNewFile", "BufRead" }, {
  pattern = "*.json",
  callback = function() vim.bo.filetype = "javascript" end,
})

-- Text files: soft wrap
au({ "BufEnter" }, {
  pattern = { "*.txt", "*.text" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.list = false
    vim.opt_local.textwidth = 0
    vim.opt_local.wrapmargin = 5
  end,
})

-- C/C++: autoindent
au({ "BufRead", "BufNewFile" }, {
  pattern = { "*.h", "*.c", "*.cc", "*.cpp" },
  callback = function() vim.opt_local.autoindent = true end,
})

-- Restore last cursor position (not in git commits)
au("BufReadPost", {
  callback = function()
    if not vim.bo.filetype:match("^git") then
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local lcount = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= lcount then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end
  end,
})

-- Save when losing focus
au({ "BufLeave", "FocusLost" }, {
  callback = function() vim.cmd("silent! wall") end,
})

-- Poll for external file changes every 30 seconds. Was 5s, which forced a
-- full-buffer reload and redraw at arbitrary moments -- a redraw storm the
-- remote stack had to keep up with. Also check on focus//enter, which covers
-- the common "edited elsewhere, came back" case without any timer at all.
vim.fn.timer_start(30000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

au({ "FocusGained", "BufEnter" }, {
  callback = function() vim.cmd("silent! checktime") end,
})

-- Disable LSP diagnostic signs/virtual text (too noisy for code)
vim.diagnostic.config({ signs = false, virtual_text = false, underline = false })


-- Opaque background matching the terminal's own #040404. This used to be
-- `bg = "none"` (transparent), which looks identical but leaves nvim not
-- painting those cells at all -- so over ssh/mosh/herdr, stale content from
-- whatever the terminal drew previously showed through and never got
-- overwritten. Painting every cell is what makes garbling self-correct.
local term_bg = "#040404"
vim.api.nvim_set_hl(0, "Normal",     { bg = term_bg, ctermbg = "black" })
vim.api.nvim_set_hl(0, "NormalNC",   { bg = term_bg, ctermbg = "black" })
vim.api.nvim_set_hl(0, "NonText",    { bg = term_bg, ctermbg = "black" })
vim.api.nvim_set_hl(0, "LineNr",     { bg = term_bg, ctermbg = "black" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = term_bg, ctermbg = "black" })

-- Floats stay opaque and bordered. The built-in colorscheme gives NormalFloat
-- #07080d, which is indistinguishable from the terminal's own #040404 -- popups
-- (Lazy, LSP hover, Telescope preview) then have no visible edge against the
-- transparent buffer behind them.
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#161620" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#161620", fg = "#8cf8f7" })

opt.termguicolors = true

-- Spell highlight: red undercurl. herdr's frame protocol carries the undercurl
-- *style* but drops the underline *color* (its CellData has no ul-color field),
-- so under herdr the curl inherits the cell foreground and renders white. To get
-- a red squiggle there, colour the foreground red too; in plain Ghostty keep the
-- nicer white-text / red-underline look via `sp`.
if vim.env.HERDR_PANE_ID then
  vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, fg = "#ff4444", sp = "#ff4444", ctermfg = 9 })
else
  vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = "#ff4444", ctermbg = 136 })
end
