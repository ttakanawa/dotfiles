return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = false },
    picker = {
      sources = {
        explorer = {
          hidden = true,
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
