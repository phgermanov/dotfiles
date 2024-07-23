return {
  'stevearc/oil.nvim',
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup {
      delete_to_trash = true,
      default_file_explorer = false,
      float = {
        -- Padding around the floating window
        padding = 2,
        max_width = 90,
        max_height = 0,
        -- border = "rounded",
        win_options = { winblend = 0 },
      },
    }
  end,
}
