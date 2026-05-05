-- AI assistants. Both plugins wrap their respective CLIs (`claude` and
-- `codex`), so the binaries must be on PATH:
--   /Applications/cmux.app/Contents/Resources/bin/claude
--   ~/.volta/bin/codex
-- The `<leader>a` prefix is shared: <leader>a* for Claude, <leader>ax for Codex.

return {
  -- Claude Code: terminal-side integration with the `claude` CLI.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeSelectModel",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
    },
    keys = {
      { "<leader>a", nil, desc = "+ai" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude: toggle" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: focus" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff" },
    },
  },

  -- Codex: floating-terminal wrapper for the `codex` CLI.
  {
    "johnseth97/codex.nvim",
    lazy = true,
    cmd = { "Codex", "CodexToggle" },
    keys = {
      { "<leader>ax", function() require("codex").toggle() end, desc = "Codex: toggle" },
    },
    opts = {
      border = "rounded",
      width = 0.85,
      height = 0.85,
      autoinstall = false,
    },
  },
}
