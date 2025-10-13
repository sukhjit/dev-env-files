vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.keymap.set('i', 'jj', '<ESC>', { desc = 'Exit insert mode with jj' })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- move text after cursor to next line
vim.keymap.set('n', '<leader>j', 'i<CR><Esc>')

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>ql', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix [L]ist' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<M-,>', '<c-w>5<')
vim.keymap.set('n', '<M-.>', '<c-w>5>')
vim.keymap.set('n', '<M-t>', '<C-W>+')
vim.keymap.set('n', '<M-s>', '<C-W>-')

vim.keymap.set('v', 'K', ":m '<-2<CR>gv-gv")
vim.keymap.set('v', 'J', ":m '>+1<CR>gv-gv")

vim.keymap.set('n', '<leader>ll', '<cmd>call llama#init()<CR>', { desc = 'Start llama AI' })
vim.keymap.set('n', '<leader>lc', '<cmd>call llama#disable()<CR>', { desc = 'Stop llama AI' })

-- lsp
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = 'Format' })

vim.keymap.set('n', '<C-c>', ':%y+<CR>', { desc = 'Copy whole file to clipboard' })

vim.keymap.set('v', 'p', '"_dP', { desc = 'Paste without overwriting' })

vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- quick fix navigation
vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>')
vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>')

-- Terraform comment line
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'terraform',
  callback = function()
    vim.bo.commentstring = '# %s'
  end,
})
