return {
  {
    -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 500,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        css = { 'prettierd' },
        html = { 'prettierd' },
        javascript = { 'prettierd' },
        go = {
          'gofumpt',
          'goimports',
          -- 'golines',
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
    },
  },
}

