return {
  {
    "nvim-treesitter/nvim-treesitter",
    -- Pin to the legacy stable branch. The default branch was renamed to
    -- "main" which is a complete v1.0 rewrite with a different config API
    -- (no more nvim-treesitter.configs.setup, no ensure_installed table).
    -- Stay on master until the v1.0 API stabilizes; then migrate.
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
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
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    },
    config = function(_, opts)
      -- Register the community cython parser (not in nvim-treesitter's
      -- built-in registry) before setup() so ensure_installed can find it.
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
      parser_config.cython = {
        install_info = {
          url = "https://github.com/b0o/tree-sitter-cython",
          files = { "src/parser.c", "src/scanner.c" },
        },
        filetype = "cython",
      }
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
