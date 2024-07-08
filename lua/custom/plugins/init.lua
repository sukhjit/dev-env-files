return {
  {
    "tpope/vim-sleuth",

    { "numToStr/Comment.nvim", opts = {} },

    {
      "folke/tokyonight.nvim",
      priority = 1000, -- Make sure to load this before all the other start plugins.
      init = function()
        vim.cmd.colorscheme "tokyonight-night"
        vim.cmd.hi "Comment gui=none"
      end,
    },

    {
      -- Highlight todo, notes, etc in comments
      "folke/todo-comments.nvim",
      event = "VimEnter",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = { signs = false },
    },

    {
      "nvim-neo-tree/neo-tree.nvim",
      version = "*",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
      },
      cmd = "Neotree",
      keys = {
        { "\\", ":Neotree reveal<CR>", { desc = "NeoTree reveal" } },
      },
      opts = {
        filesystem = {
          window = {
            mappings = {
              ["\\"] = "close_window",
            },
          },
        },
      },
    },

    -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
    -- init.lua. If you want these files, they are in the repository, so you can just download them and
    -- place them in the correct locations.

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- require 'kickstart.plugins.debug',
    -- require 'kickstart.plugins.indent_line',
    -- require 'kickstart.plugins.lint',
    -- require 'kickstart.plugins.autopairs',
    -- require 'kickstart.plugins.neo-tree',
    -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
    -- { import = 'custom.plugins' },
  },
}
