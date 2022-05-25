vim.cmd [[
    augroup fmt
      autocmd!
      autocmd BufWritePre * Neoformat
    augroup END
]]

local opt = { noremap = true, silent = false }
vim.api.nvim_set_keymap('n', '<Leader>ff', '<CMD>Neoformat<cr>', opt)
vim.api.nvim_set_keymap('x', '<Leader>ff', '<CMD>Neoformat!<cr>', opt)
