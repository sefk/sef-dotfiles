return {
  -- Treesitter: accurate syntax highlighting and code understanding
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "bash", "c", "cpp", "go", "javascript", "json", "lua",
          "markdown", "markdown_inline", "python", "rust", "toml",
          "typescript", "vim", "vimdoc", "yaml",
        },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Git: inline hunks, blame, stage from buffer
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "+" },
          change       = { text = "~" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end
          map("n", "]c", gs.next_hunk,    { desc = "Next hunk" })
          map("n", "[c", gs.prev_hunk,    { desc = "Prev hunk" })
          map("n", "<leader>hs", gs.stage_hunk,   { desc = "Stage hunk" })
          map("n", "<leader>hr", gs.reset_hunk,   { desc = "Reset hunk" })
          map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
          map("n", "<leader>hb", gs.blame_line,   { desc = "Blame line" })
        end,
      })
    end,
  },

  -- Commenting: gcc / gc<motion>
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },


  -- Terminal in a split/float (replaces vimux)
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = { [[<C-\>]] },
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        direction = "horizontal",
        size = 15,
      })
    end,
  },
}
