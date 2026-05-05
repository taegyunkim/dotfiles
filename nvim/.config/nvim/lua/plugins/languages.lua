return {
  -- Rust: rustaceanvim wraps rust-analyzer with extra features (DAP, runnables, etc.)
  -- Do not add rust-analyzer to mason-lspconfig; rustaceanvim manages it.
  {
    "mrcjkb/rustaceanvim",
    version = "^6",
    lazy = false,
    ft = { "rust" },
  },
}
