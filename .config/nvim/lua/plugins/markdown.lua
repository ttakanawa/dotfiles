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
          -- Key must be 'todo' to replace the built-in entry, which also uses
          -- raw '[-]' and would otherwise shadow this canceled state.
          todo = {
            raw = "[-]",
            rendered = "󰅖 ",
            highlight = "RenderMarkdownUnchecked",
            scope_highlight = "@markup.strikethrough",
          },
          scheduled = {
            raw = "[<]",
            rendered = "󰃰 ",
            highlight = "RenderMarkdownInfo",
            scope_highlight = nil,
          },
        },
      },
    },
  },
}
