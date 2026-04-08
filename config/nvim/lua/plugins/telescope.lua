return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function() return vim.fn.executable("make") == 1 end,
      },
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          preview = { treesitter = false },
          mappings = {
            i = {
              ["<C-u>"] = false,
              ["<C-d>"] = false,
            },
          },
        },
      })
      pcall(telescope.load_extension, "fzf")

      local map = vim.keymap.set
      -- <C-p> as muscle-memory replacement for ctrlp
      map("n", "<C-p>",      builtin.find_files,  { desc = "Find files" })
      map("n", "<leader>ff", builtin.find_files,  { desc = "Find files" })
      -- Live grep replaces :Ack / ag
      map("n", "<leader>fg", builtin.live_grep,   { desc = "Live grep" })
      map("n", "<leader>fb", builtin.buffers,     { desc = "Find buffers" })
      map("n", "<leader>fh", builtin.help_tags,   { desc = "Help tags" })
      map("n", "<leader>fr", builtin.oldfiles,    { desc = "Recent files" })
      map("n", "<leader>gc", builtin.git_commits, { desc = "Git commits" })
    end,
  },
}
