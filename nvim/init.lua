-- Leader must be set before lazy.nvim loads any plugin keymaps.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

require("options")
require("keymaps")
require("autocmds")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "solarized" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- Source work-specific overrides if present. Prefer init.lua, fall back to vimrc.
local work_init_lua = vim.fn.expand("~/.dotfiles-work/init.lua")
local work_vimrc = vim.fn.expand("~/.dotfiles-work/vimrc")
if vim.fn.filereadable(work_init_lua) == 1 then
  dofile(work_init_lua)
elseif vim.fn.filereadable(work_vimrc) == 1 then
  vim.cmd.source(work_vimrc)
end
