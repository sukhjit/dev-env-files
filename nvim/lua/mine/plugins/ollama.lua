return {
  {
    "David-Kunz/gen.nvim",
    ft = "go",
    config = function()
      require("gen").setup {
        model = "codellama",
        host = "localhost",
        port = "11434",
      }
    end,
  },
}
