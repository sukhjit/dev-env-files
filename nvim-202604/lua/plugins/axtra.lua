vim.pack.add {
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/kdheepak/lazygit.nvim' },
  { src = 'https://github.com/greggh/claude-code.nvim' },
  { src = 'https://github.com/akinsho/bufferline.nvim' },
  { src = 'https://github.com/kdheepak/lazygit.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-tree.lua' },
}

vim.cmd.colorscheme 'tokyonight-night'

require('claude-code').setup {}

require('bufferline').setup {
  vim.keymap.set('n', '<leader>x', '<cmd>:bd<CR>', { desc = 'Close Buffer' }),
  vim.keymap.set('n', '<S-Tab>', '<cmd>:bnext<CR>', { desc = 'Next Buffer' }),
  vim.keymap.set('n', '<leader>k', '<cmd>:BufferLineCloseOthers<CR>', { desc = 'Buffer Close all but Current' }),
}

require('todo-comments').setup {
  signs = false,
}

-- lazygit
vim.keymap.set('n', '<leader>lg', '<cmd>:LazyGit<CR>', { desc = 'Open Lazy[g]it' })

require('nvim-tree').setup {
  vim.keymap.set('n', '\\', ':NvimTreeFindFile<CR>', { desc = 'Neotree reveal', silent = true }),
  sort = {
    sorter = 'case_sensitive',
  },
  disable_netrw = true,
  on_attach = function(bufnr)
    -- default mappings
    local api = require 'nvim-tree.api'
    api.map.on_attach.default(bufnr)

    vim.keymap.set('n', '\\', function()
      if vim.bo.filetype == 'NvimTree' then
        vim.cmd.NvimTreeClose()
      else
        vim.cmd.NvimTreeFindFile()
      end
    end, { desc = 'Neotree reveal', silent = true })
  end,
}
