-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

-- Prevent deleting from also copying
vim.keymap.set({ "n", "v" }, "d", '"_d', { noremap = true })
vim.keymap.set("n", "dd", '"_dd', { noremap = true })

vim.keymap.set("n", "<C-,>", "<Cmd>BufferPrevious<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-.>", "<Cmd>BufferNext<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true })

-- vim.keymap.set("n", "<C-U>", "<C-U>zz", { noremap = true })
-- vim.keymap.set("n", "<C-D>", "<C-D>zz", { noremap = true })
