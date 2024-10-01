return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")

    mc.setup()

    -- Add a cursor and jump to the next word under cursor.
    vim.keymap.set({ "n", "v" }, "<c-n>", function()
      mc.addCursor("*")
    end)

    -- Jump to the next word under cursor but do not add a cursor.
    vim.keymap.set({ "n", "v" }, "<c-s>", function()
      mc.skipCursor("*")
    end)

    -- Add and remove cursors with control + left click.
    vim.keymap.set("n", "<c-leftmouse>", mc.handleMouse)

    -- Exit multicursor mode.
    vim.keymap.set({ "n", "v" }, "<c-q>", function()
      mc.clearCursors()
      -- clear highlights
      vim.cmd("nohlsearch")
      -- clear search
      vim.fn.setreg("/", "")
    end, { desc = "Clear Cursors" })

    -- Create a cursor for each line in the visual selection and jump to the beginning of the line.
    vim.keymap.set("v", "I", mc.insertVisual)

    -- Create a cursor for each line in the visual selection and jump to the end of the line.
    vim.keymap.set("v", "A", mc.appendVisual)

    -- Customize how cursors look.
    vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "CurSearch" })
    vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "IncSearch" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledCursor", { link = "IncSearch" })
    vim.api.nvim_set_hl(0, "MultiCursorDisabledVisual", { link = "IncSearch" })
  end,
}
