local lspconfig = require('lspconfig')
local util = require('lspconfig/util')

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            env = { GOFLAGS = "-tags=integration,unit" },
            analyses = {
              fieldalignment = false,
            },
          },
        },
        on_attach = function(client, bufnr)
          if client.name == "gopls" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end,
      },
      groovyls = {
        classpath = {
          "/opt/homebrew/opt/groovy/libexec/lib",
        },
      },
    },
    inlay_hints = {
      enabled = false,
    },
    efm = {
      init_options = { documentFormatting = true },
      filetypes = { "go" },
      settings = {
        rootMarkers = {".git/"},
        languages = {
          go = {
            {
              formatCommand = "golines --max-len=120",
              formatStdin = true,
            }
          }
        }
      },
      root_dir = util.root_pattern(".git", "go.mod"),
    },
  },
}
