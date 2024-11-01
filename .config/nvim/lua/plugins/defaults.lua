return {
  {
    "ahmedkhalf/project.nvim",
    config = function(_, opts)
      opts.detection_methods = { "lsp", "pattern" }
      opts.patterns = {
        ".git",
        ".hg",
        ".svn",
      }
      require("project_nvim").setup(opts)
      require("lazyvim.util").on_load("telescope.nvim", function()
        require("telescope").load_extension("projects")
      end)
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.remove(opts.sections.lualine_c)
      opts.sections.lualine_x = {}
      opts.sections.lualine_z = {}
      opts.sections.lualine_a = {
        function()
          local mc = require("multicursor-nvim")
          local status = {}
          if mc.hasCursors() then
            status.icon = " 󰛡"
          else
            status.icon = ""
          end
          local vim_mode = require("lualine.components.mode")()
          return vim_mode .. status.icon
        end,
      }
    end,
  },
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  {
    "iguanacucumber/magazine.nvim",
    name = "nvim-cmp",
  },
}
