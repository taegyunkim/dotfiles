local opt = vim.opt

opt.number = true
opt.backspace = { "indent", "eol", "start" }
opt.history = 1000
opt.showcmd = true
opt.showmode = true
opt.visualbell = true
opt.autoread = true
opt.hidden = true

-- Swap, backup, undo
opt.swapfile = false
opt.backup = false
opt.writebackup = false
local undodir = vim.fn.expand("~/.vim/backups")
vim.fn.mkdir(undodir, "p")
opt.undodir = undodir
opt.undofile = true

-- Indentation
opt.autoindent = true
opt.smarttab = true
opt.softtabstop = 2
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

opt.wrap = true
opt.linebreak = true
opt.colorcolumn = "80"
opt.textwidth = 80

-- Folds
opt.foldmethod = "indent"
opt.foldnestmax = 3
opt.foldenable = false

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 15
opt.sidescroll = 1
opt.mouse = "a"

-- Wildmenu / completion
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.wildignore = {
  "*.o", "*.obj", "*~",
  "*vim/backups*",
  "*sass-cache*",
  "*DS_Store*",
  "vendor/rails/**",
  "vendor/cache/**",
  "*.gem",
  "log/**",
  "tmp/**",
  "*.png", "*.jpg", "*.gif",
}

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Solarized: keep cterm-mode 16-color palette set up by the terminal.
opt.termguicolors = false
opt.background = "light"

-- Disable old C/Bash plugin <C-j> override
vim.g.C_Ctrl_j = "off"
vim.g.BASH_Ctrl_j = "off"
