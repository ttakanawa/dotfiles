return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
      transparent_background = true,
      integrations = {
        aerial = true,
        barbar = true,
        cmp = true,
        diffview = true,
        fzf = true,
        gitsigns = true,
        harpoon = true,
        markdown = true,
        mason = true,
        mini = {
          enabled = true,
          indentscope_color = "",
        },
        neotree = true,
        notify = true,
        nvim_surround = true,
        nvimtree = true,
        treesitter_context = true,
        treesitter = true,
        ufo = true,
        render_markdown = true,
        telescope = {
          enabled = true,
        },
        which_key = true,
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}
