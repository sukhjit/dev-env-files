return {
  {
    "David-Kunz/gen.nvim",
    ft = "go",
    config = function()
      require("gen").setup {
        model = "llama2-uncensored",
        host = "localhost",
        port = "11434",
      }
    end,
  },
}
