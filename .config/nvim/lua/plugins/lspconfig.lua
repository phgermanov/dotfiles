return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {
        settings = {
          gopls = {
            env = { GOFLAGS = "-tags=integration,unit" },
          },
        },
      },
    },
    inlay_hints = {
      enabled = false,
    },
  },
}
