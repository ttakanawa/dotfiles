return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {
          root_markers = { "vendor", ".git" },
          init_options = {
            licenceKey = os.getenv("INTELEPHENSE_LICENSE_KEY"),
            storagePath = vim.fn.stdpath("cache") .. "/intelephense",
          },
        },
        sourcekit = {
          cmd = { "xcrun", "sourcekit-lsp" },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "swift" })
      end
    end,
  },

  -- Formatter (swiftformat) — requires: brew install swiftformat
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        swift = { "swiftformat" },
      },
    },
  },

  -- Linter (swiftlint) — requires: brew install swiftlint
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        swift = { "swiftlint" },
      },
    },
  },
}
