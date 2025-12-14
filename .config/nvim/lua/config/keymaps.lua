-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Emacs-like keybindings in Insert mode
local map = vim.keymap.set
local opts = { silent = true }

-- 行移動
map("i", "<C-a>", "<C-o>^", opts)   -- 行頭（非空白）
map("i", "<C-e>", "<C-o>$", opts)   -- 行末

-- カーソル移動
map("i", "<C-b>", "<Left>", opts)   -- 左
map("i", "<C-f>", "<Right>", opts)  -- 右
map("i", "<C-p>", "<Up>", opts)     -- 上
map("i", "<C-n>", "<Down>", opts)   -- 下

-- 削除系（Emacs互換）
map("i", "<C-d>", "<Del>", opts)    -- 次の文字を削除
map("i", "<C-h>", "<BS>", opts)     -- 前の文字を削除
map("i", "<C-k>", "<C-o>D", opts)   -- カーソル以降を削除
