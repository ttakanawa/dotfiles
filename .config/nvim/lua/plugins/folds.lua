-- Disable folds to prevent PHPDoc blocks from being folded.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { folds = { enable = false } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = { folds = { enabled = false } },
  },
}
