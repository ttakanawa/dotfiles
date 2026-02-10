return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
      transparent_background = true,
      term_colors = true,
      custom_highlights = function(colors)
        return {
          ["@markup.strong"] = { fg = colors.text, bold = true },
          ["@markup.italic"] = { fg = colors.text, italic = true },
        }
      end,
      float = {
        transparent = true,
      },
      integrations = {
        aerial = true,
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
        notify = true,
        nvim_surround = true,
        nvimtree = true,
        treesitter_context = true,
        ufo = true,
        render_markdown = true,
        telescope = {
          enabled = true,
        },
        snacks = {
          enabled = true,
          indent_scope_color = "",
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
