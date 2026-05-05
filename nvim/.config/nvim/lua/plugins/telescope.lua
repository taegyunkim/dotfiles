return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    keys = {
      { "<leader>p", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>b", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>*", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
      { "<leader>t", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>T", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
      { "<leader>?k", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "%.git/", "node_modules/", "%.pyc$" },
        },
      })
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
