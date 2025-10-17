vim.pack.add {
  {
    src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
    version = vim.version.range '3',
  },
  -- dependencies
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },

  { src = 'https://github.com/nvim-neotest/neotest' },
  -- dependencies
  { src = 'https://github.com//nvim-neotest/nvim-nio' },
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/antoinemadec/FixCursorHold.nvim' },
  {
    src = 'https://github.com/fredrikaverpil/neotest-golang',
    version = 'main',
    data = {
      run = function(_)
        vim.system({ 'go', 'install', 'gotest.tools/gotestsum@latest' }):wait()
      end,
    },
  },

  { src = 'https://github.com/David-Kunz/gen.nvim' },
  { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
  { src = 'https://github.com/echasnovski/mini.statusline' },
  { src = 'https://github.com/folke/todo-comments.nvim' },
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://github.com/ggml-org/llama.vim' },
  { src = 'https://github.com/kdheepak/lazygit.nvim' },
  { src = 'https://github.com/lewis6991/gitsigns.nvim' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
    data = {
      run = function(_)
        vim.cmd 'TSUpdate go'
      end,
    },
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
    version = 'main',
  },
  { src = 'https://github.com/olexsmir/gopher.nvim' },
  { src = 'https://github.com/romgrk/barbar.nvim' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/tpope/vim-sleuth' },
  { src = 'https://github.com/L3MON4D3/LuaSnip' },
  { src = 'https://github.com/saadparwaiz1/cmp_luasnip' },
  { src = 'https://github.com/hrsh7th/nvim-cmp' },
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp' },
  { src = 'https://github.com/hrsh7th/cmp-path' },
  { src = 'https://github.com/hrsh7th/cmp-nvim-lsp-signature-help' },
  { src = 'https://github.com/windwp/nvim-autopairs' },
  { src = 'https://github.com/lukas-reineke/indent-blankline.nvim' },
}

require('ibl').setup {}

-- autopairs
require('nvim-autopairs').setup {
  require('cmp').event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done()),
}

-- autocompletion
local luasnip = require 'luasnip'
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<C-y>'] = cmp.mapping.confirm { select = true },
    ['<CR>'] = cmp.mapping.confirm { select = true },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { 'i', 's' }),

    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'nvim_lsp_signature_help' },
  },
}

-- lazygit
vim.keymap.set('n', '<leader>lg', '<cmd>:LazyGit<CR>', { desc = 'Open Lazy[g]it' })

require('todo-comments').setup {
  signs = false,
}

require('gen').setup {
  model = 'llama3.2',
  host = 'localhost',
  port = '11434',
  display_mode = 'vertical-split', -- The display mode. Can be "float" or "split" or "horizontal-split".
  show_prompt = false, -- Shows the prompt submitted to Ollama.
  show_model = true, -- Displays which model you are using at the beginning of your chat session.
  no_auto_close = true, -- Never closes the window automatically.
  file = false, -- Write the payload to a temporary file to keep the command short.
  hidden = false, -- Hide the generation window (if true, will implicitly set `prompt.replace = true`), requires Neovim >= 0.10
  debug = false,
}

require('nvim-treesitter.configs').setup {
  ensure_installed = {
    'lua',
    'python',
    'javascript',
    'typescript',
    'vimdoc',
    'vim',
    'regex',
    'terraform',
    'sql',
    'dockerfile',
    'toml',
    'json',
    'java',
    'groovy',
    'go',
    'gitignore',
    'graphql',
    'yaml',
    'make',
    'cmake',
    'markdown',
    'markdown_inline',
    'bash',
    'tsx',
    'css',
    'html',
  },
  sync_install = false,
  auto_install = true,
  ignore_install = {},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}

-- functions/classes jump configuration
require('nvim-treesitter-textobjects').setup {
  select = {
    enable = true,
    lookahead = true,
  },
}
local nttmove = require 'nvim-treesitter-textobjects.move'
vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
  nttmove.goto_next_start('@function.outer', 'textobjects')
end, { desc = 'Jump to Next Function Start Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, ']]', function()
  nttmove.goto_next_start('@class.outer', 'textobjects')
end, { desc = 'Jump to Next Class Start Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
  nttmove.goto_next_end('@function.outer', 'textobjects')
end, { desc = 'Jump to Next Function End Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, '][', function()
  nttmove.goto_next_end('@class.outer', 'textobjects')
end, { desc = 'Jump to Next Class End Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
  nttmove.goto_previous_start('@function.outer', 'textobjects')
end, { desc = 'Jump to Previous Function Start Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, '[[', function()
  nttmove.goto_previous_start('@class.outer', 'textobjects')
end, { desc = 'Jump to Previous Class Start Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
  nttmove.goto_previous_end('@function.outer', 'textobjects')
end, { desc = 'Jump to Previous Function End Outer' })

vim.keymap.set({ 'n', 'x', 'o' }, '[]', function()
  nttmove.goto_previous_end('@class.outer', 'textobjects')
end, { desc = 'Jump to Previous Class End Outer' })

-- enable highlighting
vim.api.nvim_create_autocmd('FileType', {
  pattern = { '<filetype>' },
  callback = function()
    vim.treesitter.start()
  end,
})

require('mason').setup()
require('mason-lspconfig').setup {
  ensure_installed = {},
  automatic_installation = false,
}
require('mason-tool-installer').setup {
  ensure_installed = {
    -- lsp
    'bashls',
    'css-lsp',
    'cssls',
    'docker_compose_language_service',
    'dockerls',
    'gopls',
    'html-lsp',
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

    -- golang
    'gofumpt',
    'goimports',
    'golines',
    'gomodifytags',
    'gotests',
    'iferr',
    'impl',
    'staticcheck',
  },
  auto_update = true,
  auto_install = true,
}

vim.cmd.colorscheme 'tokyonight-night'

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

require('barbar').setup {
  vim.keymap.set('n', '<Tab>', '<cmd>:BufferNext<CR>', { desc = 'Buffer Next' }),
  vim.keymap.set('n', '<S-Tab>', '<cmd>:BufferPrevious<CR>', { desc = 'Buffer Previous' }),
  vim.keymap.set('n', '<leader>k', '<cmd>:BufferCloseAllButCurrent<CR>', { desc = 'Buffer Close all but Current' }),
  vim.keymap.set('n', '<leader>x', '<cmd>:BufferClose<CR>', { desc = 'Buffer Close' }),
}

require('conform').setup {
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    lua = { 'stylua' },
    css = { 'prettierd' },
    html = { 'prettierd' },
    javascript = { 'prettierd' },
    go = {
      'gofumpt',
      'goimports',
      'golines',
    },
    terraform = { 'terraform_fmt' },
    tf = { 'terraform_fmt' },
    ['terraform-vars'] = { 'terraform_fmt' },
    typescript = { 'prettierd' },
    json = { 'prettierd' },
    jsonc = { 'prettierd' },
    markdown = { 'prettierd' },
    python = { 'ruff_format' },
    xml = { 'xmlformatter' },
  },
}

require('gopher').setup {
  ft = 'go',
  build = function()
    vim.cmd.GoInstallDeps()
  end,
  gotests = {
    template = 'testify',
  },
}

-- mini.statusline
require('mini.statusline').setup {}
vim.cmd ':lua MiniStatusline.section_location = function() return "%2l:%-2v" end'

-- telescope
local actions = require 'telescope.actions'
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<esc>'] = actions.close,
        ['<c-enter>'] = 'to_fuzzy_refine',
        ['<C-k>'] = require('telescope.actions').move_selection_previous, -- move to prev result
        ['<C-j>'] = require('telescope.actions').move_selection_next, -- move to next result
        ['<C-l>'] = require('telescope.actions').select_default, -- open file
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
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
  },
}

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
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

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

require('gitsigns').setup {
  -- signcolumn = true,
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
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
    end, { desc = 'stage git hunk' })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
    end, { desc = 'reset git hunk' })
    -- normal mode
    map('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal { ']h', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, { desc = 'git next hunk' })
    map('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal { '[h', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, { desc = 'git prev hunk' })
    map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git [s]tage hunk' })
    map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git [r]eset hunk' })
    map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git [S]tage buffer' })
    map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git [R]eset buffer' })
    map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'git [p]review hunk' })
    map('n', '<leader>hb', function()
      gitsigns.blame_line { full = true }
    end, { desc = 'git [b]lame line' })
    map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git [d]iff against index' })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '~'
    end, { desc = 'git [D]iff against last commit' })
    -- Toggles
    map('n', '<leader>hB', gitsigns.toggle_current_line_blame, { desc = 'toggle git show [B]lame line' })
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, { desc = 'git [p]review hunk [i]nline' })
  end,
}

-- neotest
require('neotest').setup {
  adapters = {
    require 'neotest-golang' {
      go_test_args = {
        '-v',
        '-race',
      },
    },
  },
}

vim.keymap.set('n', '<leader>tt', function()
  require('neotest').run.run(vim.fn.expand '%')
end, { desc = 'Run File' })

vim.keymap.set('n', '<leader>tT', function()
  require('neotest').run.run(vim.loop.cwd())
end, { desc = 'Run All [T]ests in File' })

vim.keymap.set('n', '<leader>tr', function()
  require('neotest').run.run()
end, { desc = 'Run Nearest test' })

vim.keymap.set('n', '<leader>tl', function()
  require('neotest').run.run_last()
end, { desc = 'Run [l]ast test' })

vim.keymap.set('n', '<leader>ts', function()
  require('neotest').summary.toggle()
end, { desc = 'Toggle [s]ummary' })

vim.keymap.set('n', '<leader>to', function()
  require('neotest').output.open { enter = true, auto_close = true }
end, { desc = 'Show [o]utput' })

vim.keymap.set('n', '<leader>tO', function()
  require('neotest').output_panel.toggle()
end, { desc = 'Toggle [O]utput panel' })

vim.keymap.set('n', '<leader>tS', function()
  require('neotest').run.stop()
end, { desc = '[S]top test' })
