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
    end,
  },
  {
    "folke/flash.nvim",
    enable = false,
  },
}
