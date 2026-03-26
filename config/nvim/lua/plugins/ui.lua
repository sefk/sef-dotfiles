return {
  -- Status line: black background + dark-yellow text, matching vimrc style
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Mirror vimrc: ctermbg=black ctermfg=DarkYellow / ctermfg=gray
      local black  = "#000000"
      local yellow = "#B8860B"  -- DarkYellow
      local gray   = "#404040"

      local theme = {
        normal   = { a = { bg = yellow, fg = black, gui = "bold" },
                     b = { bg = yellow, fg = black },
                     c = { bg = yellow, fg = black } },
        insert   = { a = { bg = yellow, fg = black, gui = "bold" } },
        visual   = { a = { bg = yellow, fg = black, gui = "bold" } },
        replace  = { a = { bg = yellow, fg = black, gui = "bold" } },
        command  = { a = { bg = yellow, fg = black, gui = "bold" } },
        inactive = { a = { bg = black, fg = yellow },
                     b = { bg = black, fg = yellow },
                     c = { bg = black, fg = yellow } },
      }

      require("lualine").setup({
        options = {
          theme = theme,
          component_separators = "",
          section_separators = "",
          globalstatus = false,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },

  -- Icons (used by neo-tree, telescope, etc.)
  { "nvim-tree/nvim-web-devicons", lazy = true },
}
