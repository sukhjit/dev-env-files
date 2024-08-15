return {
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    init = function()
      vim.g.barbar_auto_setup = false

      vim.keymap.set("n", "<Tab>", "<cmd>:BufferNext<CR>", { desc = "Buffer Next" })
      vim.keymap.set("n", "<S-Tab>", "<cmd>:BufferPrevious<CR>", { desc = "Buffer Previous" })
      vim.keymap.set("n", "<leader>k", "<cmd>:BufferCloseAllButCurrent<CR>", { desc = "Buffer Close all but Current" })
      vim.keymap.set("n", "<leader>x", "<cmd>:BufferClose<CR>", { desc = "Buffer Close" })
    end,
    opts = {},
    version = "^1.0.0", -- optional: only update when a new 1.x version is released
  },
}
