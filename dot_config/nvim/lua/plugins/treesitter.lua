return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        -- install_dir = vim.fn.stdpath("data") .. "/site", -- 必要なら変更
      })

      -- main では highlight を自動でONにしないため、自分で start する
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- パーサ未導入のFTもあるので pcall 推奨
          pcall(vim.treesitter.start, args.buf)

          -- （任意）indent を treesitter ベースにする場合（experimental）
          -- README の指定どおりのクォートが必要 :contentReference[oaicite:9]{index=9}
          -- pcall(function()
          --   vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          -- end)
        end,
      })
    end,
  },
}

