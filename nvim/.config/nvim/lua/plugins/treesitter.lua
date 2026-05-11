return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").cython = {
            install_info = {
              url = "https://github.com/b0o/tree-sitter-cython",
              branch = "master",
            },
          }
        end,
      })

      require("nvim-treesitter").setup()

      local parsers = {
        "bash",
        "c",
        "cpp",
        "cython",
        "go",
        "gomod",
        "gowork",
        "json",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "rust",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      }
      require("nvim-treesitter").install(parsers)

      vim.treesitter.language.register("cython", { "cython" })

      local highlight_fts = {
        "bash",
        "c",
        "cpp",
        "cython",
        "go",
        "gomod",
        "gowork",
        "json",
        "lua",
        "markdown",
        "python",
        "query",
        "rust",
        "toml",
        "typescript",
        "typescriptreact",
        "vim",
        "help",
        "yaml",
      }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = highlight_fts,
        callback = function()
          if pcall(vim.treesitter.start) then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
