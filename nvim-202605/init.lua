require 'keymaps'
require 'options'
require 'snippets'
require 'floatterm'

-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

--  In this section we set up some autocommands to run build
--  steps for certain plugins after they are installed or updated.
local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then
      output = 'No output from build command.'
    end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- This autocommand runs after a plugin is installed or updated and
--  runs the appropriate build command for that plugin if necessary.
--
-- See `:help vim.pack-events`
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, ev.data.path)
      return
    end

    if name == 'LuaSnip' then
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
      end
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then
        vim.cmd.packadd 'nvim-treesitter'
      end
      vim.cmd 'TSUpdate'
      return
    end
  end,
})

local function gh(repo)
  return 'https://github.com/' .. repo
end

-- ==================================
-- SECTION 3: UI / CORE UX PLUGINS --
-- ==================================

vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

if vim.g.have_nerd_font then
  vim.pack.add { gh 'nvim-tree/nvim-web-devicons' }
end

vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
require('gitsigns').setup {
  signs = {
    add = { text = '+' }, ---@diagnostic disable-line: missing-fields
    change = { text = '~' }, ---@diagnostic disable-line: missing-fields
    delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
    topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
    changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
  },
  signs_staged = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'Jump to next git [c]hange' })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'Jump to previous git [c]hange' })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function()
      gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [s]tage hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'git [r]eset hunk' })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git preview hunk [i]nline' })
    map('n', '<leader>hb', function()
      gitsigns.blame_line { full = true }
    end, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, { desc = 'git [D]iff against last commit' })
    map('n', '<leader>hQ', function()
      gitsigns.setqflist 'all'
    end, { desc = 'git hunk [Q]uickfix list (all files in repo)' })
    map('n', '<leader>hq', gitsigns.setqflist, { desc = 'git hunk [q]uickfix list (all changes in this file)' })
    -- Toggles
    map('n', '<leader>hB', gitsigns.toggle_current_line_blame, { desc = 'toggle git show [B]lame line' })
    map('n', '<leader>hw', gitsigns.toggle_word_diff, { desc = '[T]oggle git intra-line [w]ord diff' })
  end,
}

vim.pack.add { gh 'folke/which-key.nvim' }
require('which-key').setup {
  -- Delay between pressing a key and opening which-key (milliseconds)
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}

vim.pack.add { gh 'folke/tokyonight.nvim' }
---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
  styles = {
    comments = { italic = false },
  },
}

vim.cmd.colorscheme 'tokyonight-night'

vim.pack.add { gh 'folke/todo-comments.nvim' }
require('todo-comments').setup { signs = false }

-- mini packages
vim.pack.add {
  gh 'nvim-mini/mini.pairs',
  gh 'nvim-mini/mini.statusline',
}
require('mini.pairs').setup {
  modes = {
    insert = true,
    command = true,
    terminal = true,
  },
}

local statusline = require 'mini.statusline'
-- Set `use_icons` to true if you have a Nerd Font
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
  return '%2l:%-2v'
end

-- [[ Fuzzy Finder (files, lsp, etc) ]]
---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  gh 'nvim-telescope/telescope-media-files.nvim',
  gh 'nvim-lua/popup.nvim',
}
if vim.fn.executable 'make' == 1 then
  table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim')
end

vim.pack.add(telescope_plugins)

-- See `:help telescope` and `:help telescope.setup()`
local actions = require 'telescope.actions'
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = actions.close,
        ['<c-enter>'] = 'to_fuzzy_refine',
        ['<C-k>'] = require('telescope.actions').move_selection_previous,
        ['<C-j>'] = require('telescope.actions').move_selection_next,
        ['<C-l>'] = require('telescope.actions').select_default,
      },
    },
  },
  pickers = {
    find_files = {
      file_ignore_patterns = { 'node_modules', '.git', '.venv' },
      hidden = true,
    },
  },
  live_grep = {
    file_ignore_patterns = { 'node_modules', '.git', '.venv' },
    additional_args = function(_)
      return { '--hidden' }
    end,
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
    media_files = {
      filetypes = { 'png', 'jpg', 'jpeg', 'gif', 'mp4', 'mov', 'avi', 'mkv', 'webm', 'mp3', 'wav', 'ogg', 'flac' },
      file_cmd = 'rg',
    },
  },
}

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension 'media_files')

-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>sm', require('telescope').extensions.media_files.media_files, { desc = '[S]earch [M]edia Files' })
vim.keymap.set('n', '<leader>sF', function()
  builtin.find_files {
    find_command = {
      'rg',
      '--files',
      '--hidden',
      '-g',
      '!.git',
    },
  }
end, { desc = '[S]earch hidden [F]iles' })

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- =================
-- SECTION 5: LSP --
-- =================
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end
    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    -- The following two autocommands are used to highlight references of the
    -- word under your cursor when your cursor rests there for a little while.
    -- When you move your cursor, the highlights will be cleared (the second autocommand).
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
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

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

---@type table<string, vim.lsp.Config>
local servers = {
  gopls = {
    cmd = { 'gopls' },
    filetypes = { 'go', 'gomod', 'gosum', 'gowork', 'gotmpl' },
    root_markers = { 'go.mod', 'go.sum' },
    before_initcmd = { 'gopls' },
    settings = {
      gopls = {
        gofumpt = true,
        completeUnimported = true,
        hints = {
          parameterNames = true,
          assignVariableTypes = true,
        },
        usePlaceholders = true,
        analyses = {
          nilness = true,
          shadow = true,
          unusedparams = true,
          unusedwrite = true,
          useany = true,
          ST1000 = false, -- disable stupid rule
        },
        staticcheck = true,
      },
    },
  },
  html = {
    filetypes = { 'html' },
  },
  jsonls = {},
  cssls = {},
  tailwindcss = {},
  phpactor = {
    cmd = { 'phpactor', 'language-server' },
    filetypes = { 'php' },
    root_markers = { '.git', 'composer.json', '.phpactor.json', '.phpactor.yml' },
    workspace_required = true,
    init_options = {
      ['language_server_phpstan.enabled'] = false,
      ['language_server_psalm.enabled'] = false,
    },
  },
  sqlls = {},
  terraformls = {
    on_attach = function(client)
      client.server_capabilities.semanticTokensProvider = nil
    end,
  },
  yamlls = {
    settings = {
      yaml = {
        schemas = {
          -- Bitbucket's remote schema has an unresolvable root-level $ref; use patched local copy.
          [('file://' .. vim.fn.stdpath 'config' .. '/schemas/bitbucket-pipelines.json')] = 'bitbucket-pipelines.yml',
        },
      },
    },
  },
  bashls = {},
  dockerls = {},
  docker_compose_language_service = {},
  ts_ls = {},
  prettierd = {},
  pylsp = {
    settings = {
      pylsp = {
        plugins = {
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          autopep8 = { enabled = false },
          yapf = { enabled = false },
          mccabe = { enabled = false },
          pylsp_mypy = { enabled = false },
          pylsp_black = { enabled = false },
          pylsp_isort = { enabled = false },
        },
      },
    },
  },
  ruff = {
    commands = {
      ---@diagnostic disable-next-line: assign-type-mismatch
      RuffAutofix = {
        function()
          vim.lsp.buf.client:exec_cmd {
            command = 'ruff.applyAutofix',
            arguments = {
              { uri = vim.uri_from_bufnr(0) },
            },
          }
        end,
        description = 'Ruff: Fix all auto-fixable problems',
      },
      ---@diagnostic disable-next-line: assign-type-mismatch
      RuffOrganizeImports = {
        function()
          vim.lsp.buf.client:exec_cmd {
            command = 'ruff.applyOrganizeImports',
            arguments = {
              { uri = vim.uri_from_bufnr(0) },
            },
          }
        end,
        description = 'Ruff: Format imports',
      },
    },
  },
  stylua = {}, -- Used to format Lua code

  -- Special Lua Config, as recommended by neovim help docs
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
          return
        end
      end

      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {
  'bashls',
  'css-lsp',
  'cssls',
  'docker_compose_language_service',
  'dockerls',
  'gopls',
  'html-lsp',
  'phpactor',
  'jsonls',
  'lua_ls',
  'prettierd',
  'pylsp',
  'ruff',
  'sqlls',
  'stylua',
  'tailwindcss',
  'terraformls',
  'ts_ls',
  'xmlformatter',
  'yamlls',
}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- golang
  'gofumpt',
  'goimports',
  'golines',
  'gomodifytags',
  'gotests',
  'iferr',
  'impl',
  'staticcheck',
  -- rest
  'php-cs-fixer',
  'shfmt',
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end

-- ========================
-- SECTION 6: FORMATTING --
-- ========================
vim.pack.add { gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      sh = true,
      css = true,
      javascript = true,
      go = true,
      lua = true,
      php = true,
      python = true,
      qml = true,
      tf = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    else
      return nil
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    sh = { 'shfmt' },
    lua = { 'stylua' },
    css = { 'prettierd' },
    html = { 'prettierd' },
    javascript = { 'prettierd' },
    go = {
      'gofumpt',
      'goimports',
      'golines',
    },
    php = { 'php_cs_fixer' },
    terraform = { 'terraform_fmt' },
    tf = { 'terraform_fmt' },
    ['terraform-vars'] = { 'terraform_fmt' },
    typescript = { 'prettierd' },
    json = { 'prettierd' },
    jsonc = { 'prettierd' },
    markdown = { 'prettierd' },
    python = { 'ruff_format' },
    qml = { 'qmlformat' },
    xml = { 'xmlformatter' },
  },
  formatters = {
    prettierd = {
      args = { '--trailing-comma', 'none' },
    },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function()
  require('conform').format { async = true }
end, { desc = '[F]ormat buffer' })

-- =====================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS --
-- =====================================
vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {}

vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'snippet_forward', 'fallback' },
    ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 500,
    },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },
  snippets = { preset = 'default' },
  fuzzy = { implementation = 'lua' },
  signature = { enabled = true },
}

-- ========================
-- SECTION 8: TREESITTER --
-- ========================
vim.pack.add {
  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', version = 'main' },
  { src = gh 'nvim-treesitter/nvim-treesitter-context' },
}

require('treesitter-context').setup {}
require('nvim-treesitter-textobjects').setup {
  select = {
    enable = true,
    lookahead = true,
  },
}

-- Ensure basic parsers are installed
local parsers = {
  'bash',
  'c',
  'cmake',
  'comment',
  'css',
  'diff',
  'dockerfile',
  'gitcommit',
  'gitignore',
  'go',
  'html',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
  'php',
  'python',
  'regex',
  'sql',
  'terraform',
  'toml',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}
require('nvim-treesitter').install(parsers)

---@param buf integer
---@param language string
local function treesitter_try_attach(buf, language)
  -- Check if a parser exists and load it
  if not vim.treesitter.language.add(language) then
    return
  end
  -- Enable syntax highlighting and other treesitter features
  vim.treesitter.start(buf, language)

  -- Enable treesitter based indentation
  local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
  if has_indent_query then
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

local available_parsers = require('nvim-treesitter').get_available()
vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local buf, filetype = args.buf, args.match

    local language = vim.treesitter.language.get_lang(filetype)
    if not language then
      return
    end

    local installed_parsers = require('nvim-treesitter').get_installed 'parsers'

    if vim.tbl_contains(installed_parsers, language) then
      -- Enable the parser if it is already installed
      treesitter_try_attach(buf, language)
    elseif vim.tbl_contains(available_parsers, language) then
      -- If a parser is available in `nvim-treesitter`, auto-install it and enable it after the installation is done
      require('nvim-treesitter').install(language):await(function()
        treesitter_try_attach(buf, language)
      end)
    else
      -- Try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
      treesitter_try_attach(buf, language)
    end
  end,
})

-- ======================
-- SECTION 9: REST --
-- ======================

-- golang
vim.pack.add {
  { src = gh 'sukhjit/go-pkgs-check.nvim' },
  { src = gh 'sukhjit/go-test-runner.nvim' },
  { src = gh 'olexsmir/gopher.nvim' },
}

local gpc = require 'GoPkgsCheck'
gpc.setup()
vim.keymap.set('n', '<Leader>cps', gpc.show, { desc = '[Code] [P]ackage [S]how' })
vim.keymap.set('n', '<Leader>cpu', gpc.update, { desc = '[Code] [P]ackage [U]pdate' })
vim.keymap.set('n', '<Leader>cpc', gpc.clear, { desc = '[Code] [P]ackage [C]lear' })

require('go-test-runner').setup {}

---@diagnostic disable-next-line: missing-fields
require('gopher').setup {
  ft = 'go',
  build = function()
    vim.cmd.GoInstallDeps()
  end,
  gotests = {
    template = 'testify',
  },
}

-- lazygit
vim.pack.add { gh 'kdheepak/lazygit.nvim' }
vim.keymap.set('n', '<leader>lg', '<cmd>:LazyGit<CR>', { desc = 'Open Lazy[g]it' })

-- autopairs
vim.pack.add { 'https://github.com/windwp/nvim-autopairs' }
require('nvim-autopairs').setup {}

-- Neotree
vim.pack.add {
  gh 'MunifTanjim/nui.nvim',
  {
    src = gh 'nvim-neo-tree/neo-tree.nvim',
    version = vim.version.range '3',
  },
}
require('neo-tree').setup {
  close_if_last_window = true,

  vim.keymap.set('n', '\\', ':Neotree reveal<CR>', { desc = 'Neotree reveal', silent = true }),

  filesystem = {
    follow_current_file = {
      enabled = true,
    },
  },

  window = {
    mappings = {
      ['\\'] = {
        'close_window',
      },
      ['P'] = {
        'toggle_preview',
        config = {
          use_float = false,
          use_image_nvim = true,
          use_snacks_image = true,
          title = 'Neo-tree Preview',
        },
      },
    },
  },
}

-- LLM
vim.pack.add {
  gh 'ggml-org/llama.vim',
  gh 'greggh/claude-code.nvim',
  gh 'David-Kunz/gen.nvim',
}
vim.g.llama_config = {
  keymap_inst_cancel = '<Esc><Esc>',
  keymap_fim_accept_word = '<C-b>',
}

require('claude-code').setup {
  window = {
    position = 'vertical',
    split_ratio = 0.5,
  },
}

require('gen').setup {
  model = 'qwen3-coder:30b',
  host = 'localhost',
  port = '11434',
  display_mode = 'vertical-split',
  show_prompt = false,
  show_model = true,
  no_auto_close = true,
  file = false,
  hidden = false,
  debug = false,
}

-- bufferline
vim.pack.add { gh 'romgrk/barbar.nvim' }
require('barbar').setup {
  vim.keymap.set('n', '<S-Tab>', '<cmd>:BufferNext<CR>', { desc = 'Buffer Next' }),
  vim.keymap.set('n', '<C-S-Tab>', '<cmd>:BufferPrevious<CR>', { desc = 'Buffer Previous' }),
  vim.keymap.set('n', '<leader>k', '<cmd>:BufferCloseAllButCurrent<CR>', { desc = 'Buffer Close all but Current' }),
  vim.keymap.set('n', '<leader>x', '<cmd>:BufferClose<CR>', { desc = 'Buffer Close' }),
}

-- blankline
vim.pack.add { gh 'lukas-reineke/indent-blankline.nvim' }
require('ibl').setup {}
