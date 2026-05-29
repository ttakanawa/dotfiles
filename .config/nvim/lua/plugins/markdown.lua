return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        sign = true,
        icons = { " " },
        backgrounds = {},
      },
      checkbox = {
        enabled = true,
        checked = {},
        -- Extended checkbox states inspired by https://minimal.guide/checklists
        -- '[ ]' (to-do) and '[x]' (done) are native markdown grammar states.
        custom = {
          incomplete = { raw = "[/]", rendered = "󱎖 ", highlight = "RenderMarkdownWarn", scope_highlight = nil },
          canceled = {
            raw = "[-]",
            rendered = "󰅖 ",
            highlight = "RenderMarkdownUnchecked",
            scope_highlight = "@markup.strikethrough",
          },
        },
      },
    },
  },
}
