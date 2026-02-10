return {
  {
    "zk-org/zk-nvim",
    main = "zk",
    opts = {
      picker = "select",
      lsp = {
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          filetypes = { "markdown" },
        },
        auto_attach = {
          enabled = true,
        },
      },
    },
  },
}
