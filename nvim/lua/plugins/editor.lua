return {
  -- File explorer (replaces NERDTree). Edit a directory as a buffer.
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>e", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
    opts = {
      view_options = { show_hidden = true },
    },
  },

  -- Auto-pair brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Surround text objects: cs"' ds" ysiw" etc.
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- Lets `.` repeat plugin actions (e.g. nvim-surround's cs"').
  { "tpope/vim-repeat", event = "VeryLazy" },

  -- Highlight TODO/FIXME/HACK/NOTE/WARN/PERF and add :Todo* commands.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODO (Trouble)" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "TODO (Telescope)" },
    },
  },

  -- Session persistence
  { "tpope/vim-obsession", cmd = { "Obsession" } },
}
