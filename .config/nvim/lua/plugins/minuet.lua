local has_ollama = vim.fn.executable("ollama") == 1

return {
  {
    "milanglacier/minuet-ai.nvim",
    cond = has_ollama,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      -- Set before setup so the plugin doesn't override with Comment link
      vim.api.nvim_set_hl(0, "MinuetVirtualText", { fg = "#babbf1", italic = true })

      require("minuet").setup({
        notify = "warn",
        provider = "openai_fim_compatible",
        throttle = 0,
        request_timeout = 20,
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
          auto_trigger_ft = { "*" },
          auto_trigger_ignore_ft = { "TelescopePrompt", "snacks_picker_input" },
          keymap = {
            accept = "<A-A>",
            accept_line = "<A-a>",
            next = "<A-n>",
            prev = "<A-p>",
            -- dismiss is mapped manually below
            dismiss = false,
          },
        },
        enable_predicates = {
          function()
            return not vim.b.minuet_dismissed
          end,
        },
      })

      local ns = vim.api.nvim_create_namespace("minuet_thinking")
      local active_buf = nil
      local pending_requests = 0

      local function clear_thinking_indicator()
        if active_buf and vim.api.nvim_buf_is_valid(active_buf) then
          vim.api.nvim_buf_clear_namespace(active_buf, ns, 0, -1)
        end
        active_buf = nil
      end

      local function on_request_started()
        pending_requests = pending_requests + 1
        active_buf = vim.api.nvim_get_current_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        vim.api.nvim_buf_clear_namespace(active_buf, ns, 0, -1)
        vim.api.nvim_buf_set_extmark(active_buf, ns, row, 0, {
          virt_text = { { "🐑 Thinking...", "Comment" } },
          virt_text_pos = "eol",
        })
      end

      local function on_request_finished()
        pending_requests = pending_requests - 1
        if pending_requests <= 0 then
          pending_requests = 0
          clear_thinking_indicator()
        end
      end

      local function get_virtualtext_internal()
        local action = require("minuet.virtualtext").action
        for i = 1, 10 do
          local name, value = debug.getupvalue(action.is_visible, i)
          if name == "internal" and type(value) == "table" then
            return value
          end
        end
      end

      local function stop_thinking()
        pcall(function()
          require("minuet.virtualtext").action.dismiss()
        end)
        pcall(function()
          require("minuet.backends.common").terminate_all_jobs()
        end)

        -- Minuet has no public cancel API, so invalidate the active request.
        local ok, internal = pcall(get_virtualtext_internal)
        if ok and internal then
          internal.current_completion_timestamp = -1
        end

        pending_requests = 0
        clear_thinking_indicator()
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MinuetRequestStartedPre",
        callback = on_request_started,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MinuetRequestFinished",
        callback = on_request_finished,
      })

      -- Dismiss: set flag to suppress auto-trigger until next input
      vim.keymap.set("i", "<A-e>", function()
        stop_thinking()
        vim.b.minuet_dismissed = true
      end, { desc = "Minuet dismiss / stop thinking" })

      -- Clear dismissed flag when user types
      vim.api.nvim_create_autocmd("TextChangedI", {
        callback = function()
          if vim.b.minuet_dismissed then
            vim.b.minuet_dismissed = false
          end
        end,
      })
    end,
  },
}
