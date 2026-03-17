return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Replace the pretty_path component with one that shows full paths (length = 0)
    opts.sections.lualine_c[4] = { LazyVim.lualine.pretty_path({ length = 0 }) }
  end,
}
