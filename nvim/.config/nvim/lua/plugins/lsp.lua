return {
  -- Mason: install LSP servers, formatters, linters from inside Neovim.
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",
        "basedpyright",
        "ruff",
        "gopls",
        -- rust-analyzer is managed by rustaceanvim, not here.
      },
    },
  },

  -- Manual installer for non-LSP tools (formatters, linters).
  -- Lazy-loaded behind its commands so it never kicks off on startup; this
  -- avoids "Installation was aborted" errors when nvim is quit mid-install.
  -- Run :MasonToolsInstall once to install the listed tools.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
    opts = {
      run_on_start = false,
      ensure_installed = {
        "clang-format",
        "gofumpt",
        "goimports",
        "golangci-lint",
        "prettier",
      },
    },
  },

  -- LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "Saghen/blink.cmp",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local kmap = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end
          kmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
          kmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          kmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          kmap("n", "gr", vim.lsp.buf.references, "Find references")
          kmap("n", "K", vim.lsp.buf.hover, "Hover docs")
          kmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          kmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
          kmap("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
          kmap("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
        end,
      })

      vim.diagnostic.config({
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
        update_in_insert = false,
      })

      -- Configure servers via the new vim.lsp.config API (Neovim 0.11+).
      -- nvim-lspconfig provides default configs in its lsp/<name>.lua files
      -- which are auto-merged with our overrides. mason-lspconfig's
      -- automatic_enable handles vim.lsp.enable() for installed servers.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            gofumpt = true,
            staticcheck = true,
          },
        },
      })
    end,
  },

  -- Diagnostics list / quickfix replacement
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>q", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
      { "<leader>l", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols" },
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<leader>f",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        c = { "clang-format" },
        cpp = { "clang-format" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        go = { "goimports", "gofumpt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        toml = { "taplo" },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if vim.tbl_contains({ "javascript", "typescript", "toml" }, ft) then
          return { lsp_fallback = true, timeout_ms = 1000 }
        end
      end,
    },
  },
}
