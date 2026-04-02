vim.pack.add {
  { src = 'https://github.com/ggml-org/llama.vim' },
  { src = 'https://github.com/David-Kunz/gen.nvim' },
}

vim.g.llama_config = {
  keymap_inst_cancel = '<Esc><Esc>',
  keymap_fim_accept_word = '<C-b>',
}

require('gen').setup {
  -- model = 'llama3.2',
  model = 'qwen3-coder:30b',
  host = 'localhost',
  port = '11434',
  display_mode = 'vertical-split',
  show_prompt = false,
  show_model = true,
  no_auto_close = true,
  file = false,
  hidden = false,
  debug = false,
}
