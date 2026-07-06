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
      pipe_table = { enabled = false },     -- table-wrap.nvim owns table rendering instead
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

  -- Display-only wide-table preview: wraps long cell content and enforces
  -- column width caps via extmarks, without touching the source buffer
  {
    "ice345/markdown-table-wrap.nvim",
    ft = { "markdown" },
    opts = {
      min_col_width = 8,
      max_col_width = 40,
    },
    keys = {
      { "<leader>mw", "<cmd>MarkdownTableTogglePreview<cr>", desc = "Toggle wrapped table preview", ft = "markdown" },
      { "<leader>mW", "<cmd>MarkdownTableFloatPreview<cr>", desc = "Float wrapped table preview", ft = "markdown" },
    },
  },
}
