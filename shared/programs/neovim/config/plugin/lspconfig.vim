filetype plugin indent on

" Avoid showing extra messages when using completion
set shortmess+=c

" Always show signcolumn so that it doesnt (dis)appear when a new error happens
set signcolumn=yes

lua <<EOF
-- vim.lsp.set_log_level("debug")
-- Enable diagnostics

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.diagnostic.get, {
    virtual_text = true,
    signs = true,
    update_in_insert = true,
  }
)

_G.open_diagnostics = function()
  local popup_buf, winnr = vim.diagnostic.open_float
  if popup_buf ~= nil then
    vim.api.nvim_buf_set_keymap(popup_buf, 'n', '<ESC>', '<CMD>bdelete<CR>', {noremap = true})
  end
end
EOF

" Code navigation shortcuts
nnoremap <silent> gd         <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> K          <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD         <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k>      <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 0gD        <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr         <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g-1        <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW         <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> <c-]>      <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> <Leader>rn <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <silent> ga         <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> <Leader>fm <cmd>lua vim.lsp.buf.formatting()<CR>

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300

" Show diagnostic popup on cursor hold
autocmd CursorHold * lua _G.open_diagnostics()

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *
"  \ lua require'lsp_extensions'.inlay_hints{ prefix = "", highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }
