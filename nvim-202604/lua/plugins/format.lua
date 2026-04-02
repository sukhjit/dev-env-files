vim.pack.add {
  { src = 'https://github.com/stevearc/conform.nvim' },
}

require('conform').setup {
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
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
