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
map("i", "<C-h>", "<BS>", { silent = true, remap = true }) -- Delete previous character (remap for mini.pairs)
map("i", "<C-k>", "<C-o>D", opts) -- Delete to end of line

-- Save without triggering autocmds
vim.api.nvim_create_user_command("W", "noautocmd w", {})

-- Copy file path
local relative_path_util = require("config.relative_path")

map("n", "<leader>y", function()
  local relative_path = relative_path_util.to_relative(vim.fn.expand("%:p"))
  if relative_path then
    relative_path_util.copy_to_clipboard(relative_path, "Relative path copied")
  end
end, { desc = "Copy relative path to clipboard" })

map("v", "<leader>y", function()
  local relative_path = relative_path_util.to_relative(vim.fn.expand("%:p"))
  if not relative_path then
    return
  end

  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local result = relative_path .. "#L" .. start_line
  if start_line ~= end_line then
    result = result .. "-" .. end_line
  end
  relative_path_util.copy_to_clipboard(result, "Path with range copied")
end, { desc = "Copy relative path with selection range to clipboard" })

-- Sort PHP use statements alphabetically
map("n", "<leader>su", function()
  require("config.php_use_sort").sort()
  vim.notify("Sorted use statements", vim.log.levels.INFO)
end, { desc = "Sort PHP use statements" })
