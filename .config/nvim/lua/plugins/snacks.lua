return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<M-Up>"] = { "history_back", mode = { "i", "n" } },
            ["<M-Down>"] = { "history_forward", mode = { "i", "n" } },
          },
        },
      },
      sources = {
        explorer = {
          hidden = true,
          ignored = true,
        },
        files = {
          hidden = true,
          ignored = true,
        },
        grep = {
          hidden = true,
        },
        recent = {
          filter = { cwd = true },
        },
      },
    },
  },
}
