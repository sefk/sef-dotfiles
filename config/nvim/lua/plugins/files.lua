return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<C-n>",      "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
      { "<leader>e",  "<cmd>Neotree focus<CR>",  desc = "Focus file tree" },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { width = 30 },
        -- ASCII only: no nerd-font glyphs, no double-width ambiguity for the
        -- remote terminal to get wrong (see ui.lua).
        default_component_configs = {
          icon = {
            folder_closed = "+",
            folder_open   = "-",
            folder_empty  = "_",
            default       = " ",
          },
          git_status = {
            symbols = {
              added = "A", modified = "M", deleted = "D", renamed = "R",
              untracked = "?", ignored = "I", unstaged = "U", staged = "S",
              conflict = "C",
            },
          },
          modified = { symbol = "*" },
        },
        filesystem = {
          filtered_items = {
            visible = false,
            hide_dotfiles = false,   -- show dotfiles
            hide_gitignored = true,
          },
          follow_current_file = { enabled = true },
        },
      })
    end,
  },
}
