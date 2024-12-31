return {
  {
    "sukhjit/go-pkgs-check.nvim",
    config = function()
      local gpc = require "GoPkgsCheck"

      gpc.setup()

      vim.keymap.set("n", "<Leader>cps", gpc.show, { desc = "[Code] [P]ackage [S]how" })
      vim.keymap.set("n", "<Leader>cpc", gpc.clear, { desc = "[Code] [P]ackage [C]lear" })
    end,
  },
}
