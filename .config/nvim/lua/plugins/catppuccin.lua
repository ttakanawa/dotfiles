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
        mason = true,
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
