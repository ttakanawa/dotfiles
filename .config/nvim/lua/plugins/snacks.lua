return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = false },
    indent = { enabled = false },
    picker = {
      sources = {
        explorer = {
          hidden = true,
          win = {
            list = {
              keys = {
                -- Copy project-relative path of the item under the cursor,
                -- matching the editor's <leader>y in keymaps.lua
                ["<leader>y"] = "copy_relative_path",
              },
            },
          },
          actions = {
            copy_relative_path = function(_, item)
              if not item then
                vim.notify("No file path to copy", vim.log.levels.WARN)
                return
              end

              local relative_path_util = require("config.relative_path")
              local relative_path = relative_path_util.to_relative(Snacks.picker.util.path(item))
              if relative_path then
                relative_path_util.copy_to_clipboard(relative_path, "Relative path copied")
              end
            end,
          },
        },
        files = {
          hidden = true,
        },
        grep = {
          hidden = true,
          regex = false,
        },
        recent = {
          filter = { cwd = true },
        },
      },
      win = {
        input = {
          keys = {
            ["<M-Up>"] = { "history_back" },
            ["<M-Down>"] = { "history_forward" },
          },
        },
      },
    },
  },
}
