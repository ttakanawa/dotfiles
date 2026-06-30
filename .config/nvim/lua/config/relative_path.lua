-- Helpers for copying a project-relative file path to the clipboard.
-- Shared between the editor keymaps (config/keymaps.lua) and the snacks
-- explorer action (plugins/snacks.lua) so both behave identically.
local M = {}

-- Copy `path` to the system clipboard (+ register) and notify the user.
function M.copy_to_clipboard(path, description)
  if path and path ~= "" then
    vim.fn.setreg("+", path)
    vim.notify(description .. ": " .. path, vim.log.levels.INFO)
  else
    vim.notify("No file path to copy", vim.log.levels.WARN)
  end
end

-- Convert an absolute path to a path relative to the current working
-- directory. Directories gain a trailing slash. Returns nil (and notifies)
-- when the path is empty or lies outside the cwd.
function M.to_relative(absolute_path)
  if not absolute_path or absolute_path == "" then
    vim.notify("No file path to copy", vim.log.levels.WARN)
    return nil
  end

  local cwd = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(absolute_path, ":s?" .. cwd .. "/??")

  if relative_path == absolute_path then
    vim.notify("File is outside current working directory", vim.log.levels.ERROR)
    return nil
  end

  if vim.fn.isdirectory(absolute_path) == 1 and relative_path:sub(-1) ~= "/" then
    relative_path = relative_path .. "/"
  end

  return relative_path
end

return M
