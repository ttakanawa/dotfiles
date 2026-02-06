-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Emacs-like keybindings in Insert mode
local map = vim.keymap.set
local opts = { silent = true }

-- Line movement
map("i", "<C-a>", "<C-o>^", opts) -- Beginning of line (non-whitespace)
map("i", "<C-e>", "<C-o>$", opts) -- End of line

-- Cursor movement
map("i", "<C-b>", "<Left>", opts) -- Left
map("i", "<C-f>", "<Right>", opts) -- Right
map("i", "<C-p>", "<Up>", opts) -- Up
map("i", "<C-n>", "<Down>", opts) -- Down

-- Deletion (Emacs compatible)
map("i", "<C-d>", "<Del>", opts) -- Delete next character
map("i", "<C-h>", "<BS>", opts) -- Delete previous character
map("i", "<C-k>", "<C-o>D", opts) -- Delete to end of line

-- Copy file path
