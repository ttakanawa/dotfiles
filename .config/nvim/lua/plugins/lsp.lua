return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          root_markers = { "vendor" },
          init_options = {
            licenceKey = os.getenv("INTELEPHENSE_LICENSE_KEY"),
            storagePath = vim.fn.stdpath("cache") .. "/intelephense",
          },
        },
      },
    },
  },
}
