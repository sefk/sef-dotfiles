return {
  -- IDE integration for a Claude Code instance launched and managed externally
  -- (`claude --ide` in your own window), over the same WebSocket MCP protocol
  -- the official VS Code / JetBrains extensions use.
  --
  -- Loaded eagerly rather than on cmd/keys: the CLI discovers Neovim by reading
  -- ~/.claude/ide/<port>.lock, which only exists once the plugin has started its
  -- server. A lazy spec would leave nothing for `claude --ide` to find.
  --
  -- snacks.nvim is omitted -- it only backs the plugin-managed terminal, which
  -- this config does not use.
  {
    "coder/claudecode.nvim",
    event = "VeryLazy",
    opts = {},

    keys = {
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "neo-tree", "NvimTree", "oil", "minifiles", "netrw", "snacks_picker_list" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
      { "<leader>ai", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude IDE status" },
    },
  },
}
