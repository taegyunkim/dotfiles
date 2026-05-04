local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Strip trailing whitespace on save without moving the cursor.
local trim = augroup("StripTrailingWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = trim,
  pattern = "*",
  callback = function()
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- Silence notifications during shutdown. Mason's async installers fire
-- "Installation was aborted" via vim.notify when their jobs are killed on
-- quit; those messages aren't actionable and just clutter the screen.
autocmd("VimLeavePre", {
  group = augroup("SilenceShutdownNotifications", { clear = true }),
  callback = function()
    vim.notify = function() end
  end,
})
