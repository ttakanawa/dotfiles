local M = {}

function M.sort()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local block_start = nil
  local block_end = nil

  for i, line in ipairs(lines) do
    if line:match("^use%s+") then
      if not block_start then
        block_start = i
      end
      block_end = i
    elseif block_start and not line:match("^%s*$") then
      break
    end
  end

  if not block_start then
    return
  end

  local use_lines = {}
  for i = block_start, block_end do
    if lines[i]:match("^use%s+") then
      table.insert(use_lines, lines[i])
    end
  end

  table.sort(use_lines)
  vim.api.nvim_buf_set_lines(0, block_start - 1, block_end, false, use_lines)
end

return M
