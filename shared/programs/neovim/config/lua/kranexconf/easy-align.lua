local map = vim.api.nvim_set_keymap
local opts = { silent = true }

map('x', '<Leader>ga', '<Plug>(EasyAlign)', opts)
map('n', '<Leader>ga', '<Plug>(EasyAlign)', opts)
