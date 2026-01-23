return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "InsertEnter",

    init = function()
      if (vim.env.OPENROUTER_API_KEY or "") ~= "" then
        return
      end

      local key_file = vim.env.OPENROUTER_API_KEY_FILE
      if not key_file or key_file == "" then
        return
      end

      local ok, lines = pcall(vim.fn.readfile, key_file)
      if ok and lines and lines[1] and vim.trim(lines[1]) ~= "" then
        vim.env.OPENROUTER_API_KEY = vim.trim(lines[1])
      end
    end,

    config = function()
      require("minuet").setup({
        provider = "openai_compatible",

        request_timeout = 8.0,
        throttle = 1500,
        debounce = 600,

        -- 自動補完を使う
        blink = { enable_auto_complete = true },

        provider_options = {
          openai_compatible = {
            api_key = "OPENROUTER_API_KEY",
            end_point = "https://openrouter.ai/api/v1/chat/completions",
            model = "openai/gpt-oss-120b",
            name = "Openrouter",

            -- ★ まずは streaming を切る（重要）
            stream = false,

            optional = {
              -- thinking が必須な経路なので “無効化” はしない
              reasoning = {
                effort = "minimal",  -- まずは minimal / low を推奨
                exclude = true,      -- reasoning をレスポンスに含めない（見た目を補完向きに）
              },

              -- 補完なので短め。まずは 128〜256 で様子見
              max_tokens = 192,

              -- 出力がだらだら伸びるのを抑える（好みで）
              stop = { "\n\n" },

              top_p = 0.9,
              provider = { sort = "throughput" },
            },
          },
        },


        -- 必要なときだけ切替用（手動で）
        presets = {
          quality_manual = {
            provider = "openai_compatible",
            request_timeout = 8,
            throttle = 2500,
            debounce = 900,
            provider_options = {
              openai_compatible = {
                api_key = "OPENROUTER_API_KEY",
                end_point = "https://openrouter.ai/api/v1/chat/completions",
                model = "google/gemini-3-flash-preview",
                name = "Openrouter",
                optional = { max_tokens = 128, top_p = 0.9 },
              },
            },
          },
        },
      })

      -- 念のため起動時に自動補完を有効化
      vim.schedule(function()
        pcall(vim.cmd, "Minuet blink enable")
      end)
    end,
  },
}

