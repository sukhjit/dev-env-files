vim.pack.add {
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' },
  { src = 'https://github.com/mason-org/mason-lspconfig.nvim' },
  { src = 'https://github.com/mason-org/mason.nvim' },
}

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
    'shfmt',
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
