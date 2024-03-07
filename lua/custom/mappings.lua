local M = {}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line"
    },
    ["<leader>dus"] = {
      function ()
        local widgets = require('dap.ui.widgets');
        local sidebar = widgets.sidebar(widgets.scopes);
        sidebar.open();
      end,
      "Open debugging sidebar"
    }
  }
}

M.dap_go = {
  plugin = true,
  n = {
    ["<leader>dgt"] = {
      function()
        require('dap-go').debug_test()
      end,
      "Debug go test"
    },
    ["<leader>dgl"] = {
      function()
        require('dap-go').debug_last()
      end,
      "Debug last go test"
    }
  }
}

M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags"
    },
    ["<leader>gsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
      "Add yaml struct tags"
    },
    ["<leader>gsr"] = {
      function()
        vim.lsp.buf.rename()
      end,
      "Rename item",
    },
  }
}

M.gitsigns = {
  plugin = true,
  n = {
    ["<leader>gp"] = {
      "<cmd> Gitsigns preview_hunk <CR>",
      "Git preview change"
    },
    ["<leader>gt"] = {
      "<cmd> Gitsigns toggle_current_line_blame <CR>",
      "Git toggle line blame"
    },
  }
}

M.neotest = {
  plugin = true,
  n = {
    ["<leader>gtr"] = {
      function ()
        local nt = require("neotest")
        -- nt.output_panel.open()
        nt.run.run()
      end,
      "Run Go Test"
    },
    ["<leader>gtp"] = {
      function ()
        require('neotest').output_panel.toggle()
      end,
      "Toggle NeoTest Output panel"
    },
  }
}


return M
