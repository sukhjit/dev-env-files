vim.g.mapleader = " "

vim.g.have_nerd_font = true

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local set = vim.keymap.set

set("i", "jj", "<ESC>", { desc = "Exit insert mode with jj" })
set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

set("n", "<M-,>", "<c-w>5<")
set("n", "<M-.>", "<c-w>5>")
set("n", "<M-t>", "<C-W>+")
set("n", "<M-s>", "<C-W>-")

-- Buffer
set("n", "<Tab>", "<cmd>:BufferNext<CR>", { desc = "Buffer Next" })
set("n", "<S-Tab>", "<cmd>:BufferPrevious<CR>", { desc = "Buffer Previous" })
set("n", "<leader>k", "<cmd>:BufferCloseAllButCurrent<CR>", { desc = "Buffer Close all but Current" })
set("n", "<leader>x", "<cmd>:BufferClose<CR>", { desc = "Buffer Close" })

set("v", "K", ":m '<-2<CR>gv-gv")
set("v", "J", ":m '>+1<CR>gv-gv")
