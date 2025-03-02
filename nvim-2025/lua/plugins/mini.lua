return {
  {
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      require('mini.surround').setup()

      -- Simple and easy statusline.
      local statusline = require 'mini.statusline'
      statusline.setup {
        use_icons = vim.g.have_nerd_font,
      }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      require('mini.map').setup()

      vim.keymap.set('n', '<Leader>mc', MiniMap.close, { desc = '[M]inimap [C]lose' })
      vim.keymap.set('n', '<Leader>mf', MiniMap.toggle_focus, { desc = '[M]inimap Toggle [F]ocus' })
      vim.keymap.set('n', '<Leader>mo', MiniMap.open, { desc = '[M]inimap [O]pen' })
      vim.keymap.set('n', '<Leader>mr', MiniMap.refresh, { desc = '[M]inimap [R]efresh' })
      vim.keymap.set('n', '<Leader>ms', MiniMap.toggle_side, { desc = '[M]inimap Toggle [S]ide' })
      vim.keymap.set('n', '<Leader>mt', MiniMap.toggle, { desc = '[M]inimap, [T]oggle' })
    end,
  },
}
