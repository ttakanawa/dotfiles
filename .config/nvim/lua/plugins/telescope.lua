return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      pickers = {
        live_grep = {
          -- live_grep (sg) を実行する時だけ、強制的に隠しファイル設定を追加する
          additional_args = function(_)
            return { "--hidden", "--glob", "!.git/*" }
          end,
        },
        find_files = {
          -- ファイル検索 (ff) でも隠しファイルを表示
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/*" },
        },
      },
    },
  },
}
