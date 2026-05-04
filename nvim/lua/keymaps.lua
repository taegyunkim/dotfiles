local map = vim.keymap.set

-- Clear search highlight by double tapping //
map("n", "//", "<cmd>nohlsearch<cr>", { silent = true })

-- Move between split windows by using Ctrl+h,l,j,k
map("n", "<C-h>", "<C-w>h", { silent = true })
map("n", "<C-l>", "<C-w>l", { silent = true })
map("n", "<C-k>", "<C-w>k", { silent = true })
map("n", "<C-j>", "<C-w>j", { silent = true })

-- Create window splits
map("n", "vv", "<C-w>v", { silent = true })
map("n", "ss", "<C-w>s", { silent = true })

-- Move between buffers
map("n", "<C-n>", "<cmd>bn<cr>", { silent = true })
map("n", "<C-p>", "<cmd>bp<cr>", { silent = true })

-- Copy to system clipboard
map("v", "<leader>y", '"*y', { silent = true })
