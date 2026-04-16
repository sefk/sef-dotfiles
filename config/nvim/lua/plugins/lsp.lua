return {
  -- Mason: GUI for installing LSP servers, formatters, linters
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- Bridge: auto-install servers and wire them to vim.lsp.enable
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",   -- Lua
          "pyright",  -- Python
          "ts_ls",    -- TypeScript / JavaScript
          "bashls",   -- Bash
        },
        automatic_enable = true,  -- calls vim.lsp.enable() for each installed server
      })
    end,
  },

  -- nvim-lspconfig: provides server default configs (cmd, filetypes, root_dir)
  -- nvim 0.11+: use vim.lsp.config / vim.lsp.enable instead of lspconfig[x].setup()
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      { "j-hui/fidget.nvim", opts = {} },  -- LSP progress in bottom-right
    },
    config = function()
      -- blink.cmp enhances capabilities if loaded
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      -- Global config applied to every server
      vim.lsp.config("*", {
        on_attach = function(_, bufnr)
          local function map(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end
          map("gd",         vim.lsp.buf.definition,    "Go to definition")
          map("gr",         vim.lsp.buf.references,    "References")
          map("gI",         vim.lsp.buf.implementation,"Implementation")
          map("K",          vim.lsp.buf.hover,         "Hover docs")
          map("<leader>rn", vim.lsp.buf.rename,        "Rename")
          map("<leader>ca", vim.lsp.buf.code_action,   "Code action")
          map("<leader>d",  vim.diagnostic.open_float, "Open diagnostic")
          map("[d",         vim.diagnostic.goto_prev,  "Prev diagnostic")
          map("]d",         vim.diagnostic.goto_next,  "Next diagnostic")
        end,
        capabilities = capabilities,
      })

      -- Lua: teach it about vim globals
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { globals = { "vim" } },
          },
        },
      })
    end,
  },

  -- Completion: blink.cmp (disabled — too noisy for prose editing)
  -- {
  --   "saghen/blink.cmp",
  --   version = "*",
  --   dependencies = { "rafamadriz/friendly-snippets" },
  --   opts = {
  --     keymap = { preset = "default" },
  --     appearance = { use_nvim_cmp_as_default = false },
  --     sources = {
  --       default = { "lsp", "path", "snippets", "buffer" },
  --     },
  --     signature = { enabled = true },
  --   },
  -- },
}
