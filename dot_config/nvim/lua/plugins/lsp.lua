  return {
    -- LSP config collection
    {
      "neovim/nvim-lspconfig",
      event = { "BufReadPre", "BufNewFile" },
      dependencies = {
        "saghen/blink.cmp",
      },
      config = function()
        local ok_blink, blink = pcall(require, "blink.cmp")
        local capabilities = ok_blink and blink.get_lsp_capabilities()
          or vim.lsp.protocol.make_client_capabilities()

        if type(vim.lsp.config) ~= "function" or type(vim.lsp.enable) ~= "function" then
          return
        end

        local servers = {
          lua_ls = {
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                telemetry = { enable = false },
              },
            },
          },
          nil_ls = {
            settings = {
              ["nil"] = {
                nix = {
                  flake = {
                    autoArchive = true,
                  },
                },
              },
            },
          },
          ts_ls = {},
          pyright = {},
          bashls = {},
        }

        local server_cmd = {
          lua_ls = "lua-language-server",
          nil_ls = "nil",
          ts_ls = "typescript-language-server",
          pyright = "pyright-langserver",
          bashls = "bash-language-server",
        }

        for name, opts in pairs(servers) do
          local cmd = server_cmd[name]
          if cmd and vim.fn.executable(cmd) == 0 then
            goto continue
          end
          opts.capabilities = capabilities
          vim.lsp.config(name, opts)
          vim.lsp.enable(name)
          ::continue::
        end
      end,
    },
  }
