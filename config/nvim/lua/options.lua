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

-- Poll for external file changes every 5 seconds
vim.fn.timer_start(5000, function()
  vim.cmd("silent! checktime")
end, { ["repeat"] = -1 })

-- Disable LSP diagnostic signs/virtual text (too noisy for code)
vim.diagnostic.config({ signs = false, virtual_text = false, underline = false })


-- Transparent background: inherit terminal black
vim.api.nvim_set_hl(0, "Normal",     { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "NormalNC",   { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "NonText",    { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "LineNr",     { bg = "none", ctermbg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none", ctermbg = "none" })

-- Spell highlight: red undercurl (uses tmux undercurl passthrough)
vim.api.nvim_set_hl(0, "SpellBad", { undercurl = true, sp = "#ff4444", ctermbg = 136 })
