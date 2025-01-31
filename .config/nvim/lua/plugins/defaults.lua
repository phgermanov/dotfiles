local function removeStart(t, n)
  for _ = 1, n do
    table.remove(t, 1)
  end
end

local function removeEnd(t, n)
  for _ = 1, n do
    table.remove(t)
  end
end

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.section_separators = { left = "", right = "" }
      opts.sections.lualine_b = {}
      removeStart(opts.sections.lualine_c, 1)
      removeEnd(opts.sections.lualine_c, 1)
      removeStart(opts.sections.lualine_x, 5)
      opts.sections.lualine_y = {}
      opts.sections.lualine_z = {
        function()
          return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        end,
      }
      local catppuccin = require("catppuccin.utils.lualine")("mocha")
      catppuccin.normal.c = { bg = "#1e1e2e" }
      catppuccin.normal.z = { bg = "#1e1e2e" }
      catppuccin.insert.z = { bg = "#1e1e2e" }
      catppuccin.visual.z = { bg = "#1e1e2e" }
      catppuccin.terminal.z = { bg = "#1e1e2e" }
      opts.options.theme = catppuccin
    end,
  },
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        formatters = {
          file = {
            filename_first = true,
          },
        },
        reverse = true,
        layout = {
          preset = "telescope",
        },
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = true },
    },
  },
}
