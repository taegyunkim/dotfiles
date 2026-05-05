-- fzf.vim is just vimscript that shells out to the `fzf` binary on PATH.
-- Homebrew provides /opt/homebrew/bin/fzf, so no build step is needed.
return {
  { "junegunn/fzf", lazy = true },
  {
    "junegunn/fzf.vim",
    cmd = { "Files", "GFiles", "Buffers", "Rg", "Lines", "BLines", "Tags", "BTags" },
    dependencies = { "junegunn/fzf" },
    keys = {
      { "<leader>P", "<cmd>Files<cr>", desc = "fzf: files" },
      { "<leader>B", "<cmd>Buffers<cr>", desc = "fzf: buffers" },
      { "<leader>R", "<cmd>Rg<cr>", desc = "fzf: ripgrep" },
    },
  },
}
