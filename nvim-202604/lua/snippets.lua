-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('mine-last-edit-position', { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'help',
  command = 'wincmd L',
})

-- auto resize splits when the terminal's window is resized
vim.api.nvim_create_autocmd('VimResized', {
  command = 'wincmd =',
})

-- no auto continue comments on new line
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('no_auto_comment', {}),
  callback = function()
    vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

-- Auto-reload files changed outside of Neovim
local autoread_group = vim.api.nvim_create_augroup('AutoRead', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  group = autoread_group,
  desc = 'Auto check for file changes',
  callback = function()
    if vim.fn.mode() ~= 'c' then
      vim.cmd 'checktime'
    end
  end,
})

-- Notification when file changes on disk
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = autoread_group,
  desc = 'Notify when file changed on disk',
  callback = function()
    vim.notify('File changed on disk. Buffer reloaded.', vim.log.levels.INFO)
  end,
})
