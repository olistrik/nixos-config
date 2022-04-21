filetype plugin indent on

" Avoid showing extra messages when using completion
set shortmess+=c

" Always show signcolumn so that it doesnt (dis)appear when a new error happens
set signcolumn=yes

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300

lua <<EOF

  local opts = { noremap=true, silent=true }
  local nnoremap = function(map, cmd)
    vim.api.nvim_set_keymap('n', map, cmd, opts)
  end
  local bufnnoremap = function(bufnr, map, cmd)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', map, cmd, opts)
  end


  nnoremap('K',   '<cmd>lua vim.diagnostic.open_float()<CR>')
  nnoremap('g[',  '<cmd>lua vim.diagnostic.goto_prev()<CR>')
  nnoremap('g]',  '<cmd>lua vim.diagnostic.goto_next()<CR>')


  local on_attach = function(client, bufnr)
    -- vim.api.nvim_buf_set_keymap(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    bufnnoremap('gd',         '<cmd>lua vim.diagnostic.definition()<CR>')
    -- bufnnoremap('K',          '<cmd>lua vim.diagnostic.hover()')
    bufnnoremap('gD',         '<cmd>lua vim.diagnostic.implementation()<CR>')
    bufnnoremap('<C-k>',      '<cmd>lua vim.diagnostic.signature_help()<CR>')
    bufnnoremap('0gD',        '<cmd>lua vim.diagnostic.type_definition()<CR>')
    bufnnoremap('gr',         '<cmd>lua vim.diagnostic.references()<CR>')
    bufnnoremap('g-1',        '<cmd>lua vim.diagnostic.document_symbol()<CR>')
    bufnnoremap('gW',         '<cmd>lua vim.diagnostic.workspace_symbol()<CR>')
    bufnnoremap('<c-]>',      '<cmd>lua vim.diagnostic.declaration()<CR>')
    bufnnoremap('<Leader>rn', '<cmd>lua vim.diagnostic.rename()<CR>')
    bufnnoremap('ga',         '<cmd>lua vim.diagnostic.code_action()<CR>')
    bufnnoremap('<Leader>fm', '<cmd>lua vim.diagnostic.formatting()<CR>')
  end

-- vim.lsp.set_log_level("debug")
-- Enable diagnostics

-- vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
--  vim.diagnostic.get, {
--    virtual_text = true,
--    signs = true,
--    update_in_insert = true,
--  }
-- )

-- _G.open_diagnostics = function()
--   local popup_buf, winnr = vim.diagnostic.open_float()
--   if popup_buf ~= nil then
--     vim.api.nvim_buf_set_keymap(popup_buf, 'n', '<ESC>', '<CMD>bdelete<CR>', {noremap = true})
--   end
-- end
EOF

" autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
"  \ lua require'lsp_extensions'.inlay_hints{ prefix = "", highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
