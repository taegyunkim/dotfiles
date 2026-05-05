return {
  {
    "altercation/vim-colors-solarized",
    lazy = false,
    priority = 1000,
    init = function()
      vim.opt.termguicolors = false
      vim.opt.background = "light"
    end,
    config = function()
      vim.cmd.colorscheme("solarized")
    end,
  },
}
