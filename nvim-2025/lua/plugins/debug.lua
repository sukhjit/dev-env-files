return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'leoluz/nvim-dap-go',
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      local dap, dapui = require 'dap', require 'dapui'

      require('dapui').setup()
      require('dap-go').setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end

      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP Toggle [b]reakpoint' })
      vim.keymap.set('n', '<leader>dc', dap.continue, { desc = 'DAP [c]ontinue' })
      vim.keymap.set('n', '<leader>de', dap.disconnect, { desc = 'DAP [e]xit' })

      vim.fn.sign_define('DapBreakpoint', {
        text = '⏺',
        texthl = 'DapBreakpoint',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint',
      })
    end,
  },
}
