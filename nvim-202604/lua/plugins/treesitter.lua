vim.pack.add {
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
    data = {
      run = function(_)
        vim.cmd 'TSUpdate go'
      end,
    },
  },
}

local treesitter = require 'nvim-treesitter'
treesitter.install {
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
  'graphql',
  'html',
  'java',
  'javascript',
  'json',
  'lua',
  'luadoc',
  'make',
  'markdown',
  'markdown_inline',
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

local function ts_start(bufnr, parser_name)
  vim.treesitter.start(bufnr, parser_name)
  -- Use regex based syntax-highlighting as fallback as some plugins might need it
  vim.bo[bufnr].syntax = 'ON'
  -- Use treesitter for folds
  vim.wo.foldlevel = 99
  vim.wo.foldmethod = 'expr'
  vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.wo.foldtext = 'v:lua.vim.treesitter.foldtext()'
  -- Use treesitter for indentation
  vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

-- Auto-install and start parsers for any buffer
local ts_config = require 'nvim-treesitter.config'
vim.api.nvim_create_autocmd({ 'FileType' }, {
  desc = 'Enable Treesitter',
  callback = function(event)
    local bufnr = event.buf
    local filetype = event.match

    -- Skip if no filetype
    if filetype == '' then
      return
    end

    -- Get parser name based on filetype
    local parser_name = vim.treesitter.language.get_lang(filetype)

    if not parser_name then
      vim.notify(vim.inspect('No treesitter parser found for filetype: ' .. filetype), vim.log.levels.WARN)
      return
    end

    -- Try to get existing parser
    if not vim.tbl_contains(ts_config.get_available(), parser_name) then
      return
    end

    -- Start treesitter for this buffer
    ts_start(bufnr, parser_name)
  end,
})
