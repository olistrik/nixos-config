vim.g.mapleader = " "

vim.g.c_syntax_for_h = 1

vim.opt.expandtab = false
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.laststatus = 1
vim.opt.scrolloff = 5
vim.opt.clipboard = "unnamedplus"
vim.opt.incsearch = true
vim.opt.hlsearch = false
vim.opt.mouse = "nvchr" -- mouse in all modes except insert

local map = vim.api.nvim_set_keymap
local opt = { noremap = true, silent = true }

map('n', '<Leader>cq', '<CMD>cclose<cr>', opt)
map('n', '<C-j>', '<CMD>cnext<cr>', opt)
map('n', '<C-k>', '<CMD>cprev<cr>', opt)
map('n', 'n', 'nzzzv', opt)
map('n', 'N', 'Nzzzv', opt)

-- move code around
map('v', 'J', ":m '>+1<CR>gv=gv", opt)
map('v', 'K', ":m '<-2<CR>gv=gv", opt)

-- yank to eol like D
map('n', 'Y', 'yg$', opt)

map('n', '<leader>d', '"_d', opt)
map('v', '<leader>d', '"_d', opt)
