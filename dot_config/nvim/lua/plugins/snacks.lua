return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = { enabled = true },
    notifier = { enabled = true },
    bigfile = { enabled = true }, -- 任意（巨大ファイル対策）
    dashboard = {
      enabled = true,
      example = "github", -- まずは公式例で土台を作る :contentReference[oaicite:3]{index=3}
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "files",    action = function() Snacks.picker.files() end },
          { icon = " ", key = "p", desc = "projects", action = function() Snacks.picker.projects() end },
          { icon = " ", key = "r", desc = "recent",   action = function() Snacks.picker.recent() end },
          { icon = " ", key = "q", desc = "quit",     action = ":qa" },
        },
      },
    },
  },
  keys = {
    -- Bの主力：ファイル/grep/バッファ
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>/",       function() Snacks.picker.grep() end,  desc = "Grep" },
    { "<leader>,",       function() Snacks.picker.buffers() end, desc = "Buffers" },

    -- LSPでジャンプ（Bの強み）
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gr", function() Snacks.picker.lsp_references() end,  desc = "References" },
  },
}

