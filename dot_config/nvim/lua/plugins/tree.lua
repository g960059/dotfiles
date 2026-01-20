return {
  "stevearc/oil.nvim",
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  lazy = false,
  opts = {
    default_file_explorer = true,
    view_options = { show_hidden = false },
  },
  config = function(_, opts)
    require("oil").setup({
     view_options = {
      show_hidden = true,
     },
    })
    vim.keymap.set("n", "-", function() require("oil").open_float() end, { desc = "Oil (float)" })
  end,
}

