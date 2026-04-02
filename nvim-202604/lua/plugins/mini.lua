vim.pack.add {
  { src = 'https://github.com/nvim-mini/mini.notify' },
  { src = 'https://github.com/nvim-mini/mini.indentscope' },
  { src = 'https://github.com/nvim-mini/mini.pairs' },
  { src = 'https://github.com/nvim-mini/mini.statusline' },
}

require('mini.notify').setup {
  lsp_progress = {
    duration_last = 5000,
  },
}
vim.notify = require('mini.notify').make_notify()

require('mini.indentscope').setup()

require('mini.pairs').setup {
  modes = {
    insert = true,
    command = true,
    terminal = true,
  },
}

require('mini.statusline').setup {}
vim.cmd ':lua MiniStatusline.section_location = function() return "%2l:%-2v" end'
