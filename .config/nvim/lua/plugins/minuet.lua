local has_ollama = vim.fn.executable("ollama") == 1

return {
  {
    "milanglacier/minuet-ai.nvim",
    cond = has_ollama,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        notify = "warn",
        provider = "openai_fim_compatible",
        throttle = 0,
        request_timeout = 10,
        debounce = 150,
        n_completions = 1,
        context_window = 4096,
        provider_options = {
          openai_fim_compatible = {
            api_key = "TERM",
            end_point = "http://localhost:11434/v1/completions",
            model = "qwen2.5-coder:7b",
            name = "Ollama",
            stream = false,
            optional = {
              max_tokens = 256,
              top_p = 0.9,
            },
          },
        },
        virtualtext = {
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            next = "<A-n>",
            prev = "<A-p>",
            dismiss = "<A-e>",
          },
        },
      })

      local ns = vim.api.nvim_create_namespace("minuet_thinking")
      local active_buf = nil

      local function on_request_started()
        active_buf = vim.api.nvim_get_current_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_clear_namespace(active_buf, ns, 0, -1)
        vim.api.nvim_buf_set_extmark(active_buf, ns, row, 0, {
          virt_text = { { "🐑 Thinking...", "Comment" } },
          virt_text_pos = "eol",
        })
      end

      local function on_request_finished()
        if active_buf and vim.api.nvim_buf_is_valid(active_buf) then
          vim.api.nvim_buf_clear_namespace(active_buf, ns, 0, -1)
        end
        active_buf = nil
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MinuetRequestStarted",
        callback = on_request_started,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MinuetRequestFinished",
        callback = on_request_finished,
      })
    end,
  },
}
