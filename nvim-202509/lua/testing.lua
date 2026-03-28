vim.pack.add {
  {
    src = 'https://github.com/sukhjit/go-test-runner.nvim',

    -- { src = 'https://github.com/nvim-neotest/neotest' },
    -- dependencies
    -- { src = 'https://github.com/nvim-neotest/nvim-nio' },
    -- { src = 'https://github.com/antoinemadec/FixCursorHold.nvim' },
    -- {
    --   src = 'https://github.com/fredrikaverpil/neotest-golang',
    --   version = 'main',
    --   data = {
    --     run = function(_)
    --       vim.system({ 'go', 'install', 'gotest.tools/gotestsum@latest' }):wait()
    --     end,
    --   },
    -- },
  },
}

require('go-test-runner').setup {}

-- neotest
-- require('neotest').setup {
--   adapters = {
--     require 'neotest-golang' {
--       runner = 'gotestsum',
--       go_test_args = {
--         '-v',
--         '-race',
--       },
--     },
--   },
-- }
--
-- vim.keymap.set('n', '<leader>tt', function()
--   require('neotest').run.run(vim.fn.expand '%')
-- end, { desc = 'Run File' })
--
-- vim.keymap.set('n', '<leader>tT', function()
--   require('neotest').run.run(vim.loop.cwd())
-- end, { desc = 'Run All [T]ests in File' })
--
-- vim.keymap.set('n', '<leader>tr', function()
--   require('neotest').run.run()
-- end, { desc = 'Run Nearest test' })
--
-- vim.keymap.set('n', '<leader>tl', function()
--   require('neotest').run.run_last()
-- end, { desc = 'Run [l]ast test' })
--
-- vim.keymap.set('n', '<leader>ts', function()
--   require('neotest').summary.toggle()
-- end, { desc = 'Toggle [s]ummary' })
--
-- vim.keymap.set('n', '<leader>to', function()
--   require('neotest').output.open { enter = true, auto_close = true }
-- end, { desc = 'Show [o]utput' })
--
-- vim.keymap.set('n', '<leader>tO', function()
--   require('neotest').output_panel.toggle()
-- end, { desc = 'Toggle [O]utput panel' })
--
-- vim.keymap.set('n', '<leader>tS', function()
--   require('neotest').run.stop()
-- end, { desc = '[S]top test' })
