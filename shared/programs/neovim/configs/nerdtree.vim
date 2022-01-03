"" close on file open
let g:NERDTreeQuitOnOpen = 1

"" Open on F2
map <F2> :NERDTreeToggle<CR>

"" close if only thing open.
autocmd bufEnter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
