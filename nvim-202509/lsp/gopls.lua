---@type vim.lsp.Config
return {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gosum', 'gowork', 'gotmpl' },
  root_markers = { 'go.mod', 'go.sum' },
  before_initcmd = { 'gopls' },
  settings = {
    gopls = {
      gofumpt = true,
      completeUnimported = true,
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
}
