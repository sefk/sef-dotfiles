return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
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
