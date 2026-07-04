return {
  -- Live markdown preview in the browser; updates as you type
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = "cd app && npm install",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview toggle", ft = "markdown" },
    },
  },

  -- In-buffer markdown rendering (headings, tables, code blocks, checkboxes)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {
      render_modes = true,                  -- render in every mode, including insert
      anti_conceal = { enabled = false },   -- keep the cursor's line rendered too
    },
    keys = {
      { "<leader>mr", "<cmd>RenderMarkdown toggle<cr>", desc = "Render markdown toggle", ft = "markdown" },
    },
  },

  -- Table editing: cell navigation, auto-align, row/column insert/move/delete
  {
    "SCJangra/table-nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "markdown" },
    opts = {},
  },
}
