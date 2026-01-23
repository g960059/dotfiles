return {
  {
    "saghen/blink.pairs",
    version = "*", -- prebuilt 利用推奨
    dependencies = "saghen/blink.download",
    event = "InsertEnter",
    opts = {
      mappings = {
        enabled = true,
        cmdline = true,
      },
      highlights = {
        enabled = true,
        cmdline = true,
        matchparen = {
          enabled = true,
          include_surrounding = false,
        },
      },
    },
  },
}

