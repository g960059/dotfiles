require("config.lazy")

vim.opt.autoread = true
vim.opt.updatetime = 200 -- CursorHold を早める（お好みで 200〜1000）

local aug = vim.api.nvim_create_augroup("AutoReadCheckTime", { clear = true })

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  group = aug,
  callback = function()
    -- コマンドライン入力中は避ける（誤爆防止）
    if vim.fn.mode() ~= "c" then
      vim.cmd("checktime")
    end
  end,
})

-- （任意）外部更新を検知した時に通知
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = aug,
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.WARN)
  end,
})

vim.g.clipboard = {
  name = "OSC 52",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  -- WezTermは安全のため「端末からクリップボードを読む」のを許可しないので
  -- paste は端末の貼り付け(Cmd+V)を使うのが確実
  paste = {
    ["+"] = function() end,
    ["*"] = function() end,
  },
}
