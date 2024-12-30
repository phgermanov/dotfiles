return {
  {
    "catppuccin/nvim",
    priority = 1000, -- Ensure it loads first
    config = function()
      local colors = require("catppuccin/palettes").get_palette()

      require("catppuccin").setup({
        custom_highlights = {
          TelescopeMatching = { fg = colors.flamingo },
          TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

          TelescopePromptPrefix = { bg = colors.surface0 },
          TelescopePromptNormal = { bg = colors.surface0 },
          TelescopeResultsNormal = { bg = colors.mantle },
          TelescopePreviewNormal = { bg = colors.mantle },
          TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
          TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
          TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
          TelescopePromptTitle = { fg = colors.pink },
          TelescopeResultsTitle = { fg = colors.mantle },
          TelescopePreviewTitle = { fg = colors.green },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
