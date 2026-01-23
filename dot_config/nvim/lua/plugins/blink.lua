return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "milanglacier/minuet-ai.nvim",
    },

    -- 重要: opts を function にして、ロード後に require("minuet") する
    opts = function()
      local minuet = require("minuet")

      return {
        keymap = {
          preset = "default",

          -- AI(minuet)を手動呼び出し（Minuet README の推奨経路）
          ["<C-g>"] = minuet.make_blink_map(),
        },

        completion = {
          menu = { auto_show = true },
          trigger = { prefetch_on_insert = false },
          accept = { auto_brackets = { enabled = false } },
        },

        sources = {
          -- ここが肝: 手動トリガが min_keyword_length に阻まれないよう 0
          min_keyword_length = 0,

          -- AI も自動候補に混ぜる（まずは動作確認優先）
          default = { "lsp", "path", "buffer", "snippets", "minuet" },

          providers = {
            minuet = {
              name = "minuet",
              module = "minuet.blink",
              async = true,
              min_keyword_length = 0,
              -- request_timeout(秒) * 1000 に揃えるのが推奨
              timeout_ms = 8000,
              score_offset = 50,
            },
          },
        },
      }
    end,
  },
}

