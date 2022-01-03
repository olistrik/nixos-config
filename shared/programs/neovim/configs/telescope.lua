
require('telescope').setup{
  defaults = {
    file_ignore_patterns = {
      "^.git/"
    }
  }
}

vim.cmd([[
  nnoremap <silent> <C-p> <cmd>Telescope find_files hidden=true<CR>
  nnoremap <silent> <C-f> <cmd>Telescope live_grep hidden=true<CR>
]])
