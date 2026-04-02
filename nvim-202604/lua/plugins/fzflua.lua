vim.pack.add {
  'https://github.com/ibhagwan/fzf-lua',
}

local fzflua = require 'fzf-lua'
fzflua.setup {
  defaults = {
    git_icons = true,
    file_icons = true,
    color_icons = true,
  },
}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    vim.keymap.set('n', '<leader>sh', fzflua.helptags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', fzflua.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', fzflua.files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sw', fzflua.grep_cword, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', fzflua.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', fzflua.diagnostics_document, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sr', fzflua.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', fzflua.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', fzflua.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>/', fzflua.blines, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', function()
      fzflua.lines { fzf_opts = { ['--exact'] = '' } }
    end, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      fzflua.files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })

    -- LSP
    vim.keymap.set({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, { desc = '[G]oto Code [A]ction' })
    vim.keymap.set('n', 'grr', fzflua.lsp_references, { desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gri', vim.lsp.buf.implementation, { desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'grd', fzflua.lsp_definitions, { desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'grD', vim.lsp.buf.declaration, { desc = '[G]oto [D]eclaration' })
    vim.keymap.set('n', 'gO', fzflua.lsp_document_symbols, { desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW', fzflua.lsp_live_workspace_symbols, { desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', vim.lsp.buf.type_definition, { desc = '[G]oto [T]ype Definition' })

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    --    See `:help CursorHold` for information about when this is executed
    --
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end
  end,
})

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}
