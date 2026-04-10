return {
  "folke/snacks.nvim",
  opts = {
    image = { enabled = false },
    picker = {
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
