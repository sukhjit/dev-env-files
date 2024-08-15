return {
  {
    {
      "tpope/vim-fugitive",
    },

    {
      "tpope/vim-sleuth",
    },

    {
      "numToStr/Comment.nvim",
      opts = {},
    },

    {
      "folke/tokyonight.nvim",
      priority = 1000, -- Make sure to load this before all the other start plugins.
      init = function()
        vim.cmd.colorscheme "tokyonight-night"
        vim.cmd.hi "Comment gui=none"
      end,
    },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
    },
    {
      -- Highlight todo, notes, etc in comments
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
    },
  },
}
