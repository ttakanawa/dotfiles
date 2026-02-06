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
local function copy_to_clipboard(path, description)
  if path and path ~= "" then
    vim.fn.setreg("+", path)
    -- vim.fn.setreg('"', path)
    vim.notify(description .. ": " .. path, vim.log.levels.INFO)
  else
    vim.notify("No file path to copy", vim.log.levels.WARN)
  end
end

local function get_relative_path()
  local current_file = vim.fn.expand("%:p")
  local cwd = vim.fn.getcwd()

  if current_file == "" then
    vim.notify("No file path to copy", vim.log.levels.WARN)
    return nil
  end

  local relative_path = vim.fn.fnamemodify(current_file, ":s?" .. cwd .. "/??")

  if relative_path == current_file then
    vim.notify("File is outside current working directory", vim.log.levels.ERROR)
    return nil
  end

  return relative_path
end

map("n", "<leader>y", function()
  local relative_path = get_relative_path()
  if relative_path then
    copy_to_clipboard(relative_path, "Relative path copied")
  end
end, { desc = "Copy relative path to clipboard" })

map("v", "<leader>y", function()
  local relative_path = get_relative_path()
  if not relative_path then
    return
  end

  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  local result = relative_path .. "#L" .. start_line .. "-L" .. end_line
  copy_to_clipboard(result, "Path with range copied")
end, { desc = "Copy relative path with selection range to clipboard" })
