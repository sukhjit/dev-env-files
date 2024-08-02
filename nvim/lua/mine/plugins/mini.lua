return {
  {
    -- Collection of various small independent plugins/modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      require("mini.map").setup()

      -- Simple and easy statusline.
      local statusline = require "mini.statusline"
      statusline.setup {
        use_icons = true,
      }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end

      vim.keymap.set("n", "<Leader>mc", MiniMap.close, { desc = "[M]inimap [C]lose" })
      vim.keymap.set("n", "<Leader>mf", MiniMap.toggle_focus, { desc = "[M]inimap Toggle [F]ocus" })
      vim.keymap.set("n", "<Leader>mo", MiniMap.open, { desc = "[M]inimap [O]pen" })
      vim.keymap.set("n", "<Leader>mr", MiniMap.refresh, { desc = "[M]inimap [R]efresh" })
      vim.keymap.set("n", "<Leader>ms", MiniMap.toggle_side, { desc = "[M]inimap Toggle [S]ide" })
      vim.keymap.set("n", "<Leader>mt", MiniMap.toggle, { desc = "[M]inimap, [T]oggle" })
    end,
  },
}
